#include <ReiseManager/Core/Trip.hpp>
#include <stdexcept>
#include <filesystem>
#include <ctime>
#ifdef _WIN32
#include <windows.h>
#include <shobjidl.h>
#include <propvarutil.h>
#include <propkey.h>
#include <atlbase.h>
#include <atlconv.h>
#endif

using namespace ReiseManager::Core;

#ifdef _WIN32
static std::time_t FileTimeToUnixTime(const FILETIME &ft)
{
    ULARGE_INTEGER ull;
    ull.LowPart = ft.dwLowDateTime;
    ull.HighPart = ft.dwHighDateTime;
    return static_cast<std::time_t>((ull.QuadPart - 116444736000000000ULL) / 10000000ULL);
}

static void UnixTimeToFileTime(std::time_t t, FILETIME *ft)
{
    ULARGE_INTEGER ull;
    ull.QuadPart = static_cast<ULONGLONG>(t) * 10000000ULL + 116444736000000000ULL;
    ft->dwLowDateTime = ull.LowPart;
    ft->dwHighDateTime = ull.HighPart;
}
#endif

Trip::Trip(const SDNumber &sdnum, const std::string &title, const std::string &machine,
           const std::string &company, const std::string &location,
           const std::chrono::system_clock::time_point &start,
           const std::chrono::system_clock::time_point &end)
    : sdnum_(sdnum), title_(title), machine_(machine), company_(company),
      location_(location), start_(start), end_(end)
{
    if (end < start)
    {
        throw std::invalid_argument("End date must be on or after start date");
    }
}

const Trip::SDNumber &Trip::GetSDNumber() const { return sdnum_; }
const std::string &Trip::GetTitle() const { return title_; }
const std::string &Trip::GetMachine() const { return machine_; }
const std::string &Trip::GetCompany() const { return company_; }
const std::string &Trip::GetLocation() const { return location_; }
int Trip::GetDuration() const
{
    return std::chrono::duration_cast<std::chrono::hours>(end_ - start_).count() / 24 + 1;
}
const std::chrono::system_clock::time_point &Trip::GetStartDate() const { return start_; }
const std::chrono::system_clock::time_point &Trip::GetEndDate() const { return end_; }

std::string Trip::ComputeFolderName() const
{
    return sdnum_.sd + "-" + sdnum_.position;
}

Trip Trip::FromFolder(const std::filesystem::path &folderPath)
{
    SDNumber sd{"", ""};
    auto name = folderPath.filename().string();
    auto pos = name.find('-');
    if (pos != std::string::npos)
    {
        sd.sd = name.substr(0, pos);
        sd.position = name.substr(pos + 1);
    }
    std::string title, machine, company, location;
    auto start = std::chrono::system_clock::now();
    auto end = start;
#ifdef _WIN32
    auto lnk = folderPath.parent_path() / (folderPath.filename().string() + ".lnk");
    if (std::filesystem::exists(lnk))
    {
        CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
        IShellLinkW *link = nullptr;
        if (SUCCEEDED(CoCreateInstance(CLSID_ShellLink, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&link))))
        {
            IPersistFile *pf = nullptr;
            if (SUCCEEDED(link->QueryInterface(IID_PPV_ARGS(&pf))))
            {
                pf->Load(lnk.wstring().c_str(), STGM_READ);
                IPropertyStore *store = nullptr;
                if (SUCCEEDED(link->QueryInterface(IID_PPV_ARGS(&store))))
                {
                    PROPVARIANT pv;
                    if (SUCCEEDED(store->GetValue(PKEY_FileDescription, &pv)) && pv.vt == VT_LPWSTR)
                        title = CW2A(pv.pwszVal);
                    PropVariantClear(&pv);
                    // read additional properties
                    if (SUCCEEDED(store->GetValue(PKEY_Title, &pv)) && pv.vt == VT_LPWSTR)
                        ; // ignore title which stores folder name
                    PropVariantClear(&pv);
                    if (SUCCEEDED(store->GetValue(PKEY_Company, &pv)) && pv.vt == VT_LPWSTR)
                        company = CW2A(pv.pwszVal);
                    PropVariantClear(&pv);
                    if (SUCCEEDED(store->GetValue(PKEY_Category, &pv)) && pv.vt == VT_LPWSTR)
                        machine = CW2A(pv.pwszVal);
                    PropVariantClear(&pv);
                    if (SUCCEEDED(store->GetValue(PKEY_Calendar_Location, &pv)) && pv.vt == VT_LPWSTR)
                        location = CW2A(pv.pwszVal);
                    PropVariantClear(&pv);
                    if (SUCCEEDED(store->GetValue(PKEY_StartDate, &pv)) && pv.vt == VT_FILETIME)
                        start = std::chrono::system_clock::from_time_t(FileTimeToUnixTime(pv.filetime));
                    PropVariantClear(&pv);
                    if (SUCCEEDED(store->GetValue(PKEY_EndDate, &pv)) && pv.vt == VT_FILETIME)
                        end = std::chrono::system_clock::from_time_t(FileTimeToUnixTime(pv.filetime));
                    PropVariantClear(&pv);
                    store->Release();
                }
                pf->Release();
            }
            link->Release();
        }
        CoUninitialize();
    }
#endif
    return Trip(sd, title, machine, company, location, start, end);
}

void Trip::ApplyToShortcut(const std::filesystem::path &shortcutPath) const
{
#ifdef _WIN32
    CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    IShellLinkW *link = nullptr;
    if (FAILED(CoCreateInstance(CLSID_ShellLink, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&link))))
        throw std::runtime_error("Failed to create shell link");
    std::filesystem::path target = shortcutPath;
    target.replace_extension();
    link->SetPath(target.wstring().c_str());
    IPropertyStore *store = nullptr;
    if (SUCCEEDED(link->QueryInterface(IID_PPV_ARGS(&store))))
    {
        PROPVARIANT pv;
        // folder name as title
        InitPropVariantFromString(CA2W(ComputeFolderName().c_str()), &pv);
        store->SetValue(PKEY_Title, pv);
        PropVariantClear(&pv);
        // human friendly description
        InitPropVariantFromString(CA2W(title_.c_str()), &pv);
        store->SetValue(PKEY_FileDescription, pv);
        PropVariantClear(&pv);
        InitPropVariantFromString(CA2W(company_.c_str()), &pv);
        store->SetValue(PKEY_Company, pv);
        PropVariantClear(&pv);
        InitPropVariantFromString(CA2W(machine_.c_str()), &pv);
        store->SetValue(PKEY_Category, pv);
        PropVariantClear(&pv);
        InitPropVariantFromString(CA2W(location_.c_str()), &pv);
        store->SetValue(PKEY_Calendar_Location, pv);
        PropVariantClear(&pv);
        FILETIME ftStart, ftEnd;
        UnixTimeToFileTime(std::chrono::system_clock::to_time_t(start_), &ftStart);
        UnixTimeToFileTime(std::chrono::system_clock::to_time_t(end_), &ftEnd);
        InitPropVariantFromFileTime(&ftStart, &pv);
        store->SetValue(PKEY_StartDate, pv);
        PropVariantClear(&pv);
        InitPropVariantFromFileTime(&ftEnd, &pv);
        store->SetValue(PKEY_EndDate, pv);
        PropVariantClear(&pv);
        wchar_t dur[32];
        swprintf(dur, 32, L"%d Tage", GetDuration());
        InitPropVariantFromString(dur, &pv);
        store->SetValue(PKEY_Duration, pv);
        PropVariantClear(&pv);
        store->Commit();
        store->Release();
    }
    IPersistFile *pf = nullptr;
    link->QueryInterface(IID_PPV_ARGS(&pf));
    pf->Save(shortcutPath.wstring().c_str(), TRUE);
    pf->Release();

    HANDLE hFile = CreateFileW(shortcutPath.wstring().c_str(), GENERIC_WRITE, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (hFile != INVALID_HANDLE_VALUE)
    {
        FILETIME ftStart;
        UnixTimeToFileTime(std::chrono::system_clock::to_time_t(start_), &ftStart);
        SetFileTime(hFile, &ftStart, nullptr, &ftStart);
        CloseHandle(hFile);
    }

    link->Release();
    CoUninitialize();
#else
    (void)shortcutPath; // unused
#endif
}
