#include <ReiseManager/UI/TripDialog.hpp>
#include <commctrl.h>
#include <stdexcept>
#include <sstream>
#include <ctime>

using namespace ReiseManager::UI;

TripDialog::TripDialog(bool modeNew, const std::filesystem::path &targetPath)
    : modeNew_(modeNew), targetPath_(targetPath)
{
#ifdef _WIN32
    if (!modeNew_ && !targetPath_.empty())
    {
        std::filesystem::path folder = targetPath_;
        if (folder.extension() == L".lnk")
        {
            folder = folder.parent_path() / folder.stem();
        }
        if (std::filesystem::exists(folder))
        {
            trip_ = ReiseManager::Core::Trip::FromFolder(folder);
        }
    }
#else
    (void)targetPath_;
#endif
}

int TripDialog::Show(HINSTANCE hInstance, HWND hParent)
{
#ifdef _WIN32
    INITCOMMONCONTROLSEX icc{sizeof(icc), ICC_DATE_CLASSES};
    InitCommonControlsEx(&icc);

    static const wchar_t CLASS_NAME[] = L"ReiseManagerTripDialog";
    static bool registered = false;
    if (!registered)
    {
        WNDCLASSEXW wc{sizeof(wc)};
        wc.lpfnWndProc = [](HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam) -> LRESULT
        {
            TripDialog *dlg = reinterpret_cast<TripDialog *>(GetWindowLongPtrW(hWnd, GWLP_USERDATA));
            switch (msg)
            {
            case WM_CREATE:
            {
                auto cs = reinterpret_cast<CREATESTRUCTW *>(lParam);
                dlg = reinterpret_cast<TripDialog *>(cs->lpCreateParams);
                SetWindowLongPtrW(hWnd, GWLP_USERDATA, (LONG_PTR)dlg);
                dlg->hwnd_ = hWnd;
                HINSTANCE hInst = cs->hInstance;
                int y = 10;
                auto makeLabel = [&](int id, const wchar_t *text)
                { CreateWindowW(L"STATIC", text, WS_CHILD | WS_VISIBLE, 10, y, 80, 20, hWnd, (HMENU)id, hInst, nullptr); };
                auto makeEdit = [&](int id, const wchar_t *txt)
                {HWND h=CreateWindowExW(WS_EX_CLIENTEDGE,L"EDIT",txt,WS_CHILD|WS_VISIBLE|ES_AUTOHSCROLL,100,y,200,20,hWnd,(HMENU)id,hInst,nullptr);y+=25;return h; };
                makeLabel(1, L"SD");
                dlg->edSd_ = makeEdit(101, dlg->modeNew_ ? L"" : std::wstring(dlg->trip_.GetSDNumber().sd.begin(), dlg->trip_.GetSDNumber().sd.end()).c_str());
                makeLabel(2, L"Pos");
                dlg->edPos_ = makeEdit(102, dlg->modeNew_ ? L"" : std::wstring(dlg->trip_.GetSDNumber().position.begin(), dlg->trip_.GetSDNumber().position.end()).c_str());
                makeLabel(3, L"Titel");
                dlg->edTitle_ = makeEdit(103, std::wstring(dlg->modeNew_ ? L"" : std::wstring(dlg->trip_.GetTitle().begin(), dlg->trip_.GetTitle().end())).c_str());
                makeLabel(4, L"Maschine");
                dlg->edMachine_ = makeEdit(104, std::wstring(dlg->modeNew_ ? L"" : std::wstring(dlg->trip_.GetMachine().begin(), dlg->trip_.GetMachine().end())).c_str());
                makeLabel(5, L"Firma");
                dlg->edCompany_ = makeEdit(105, std::wstring(dlg->modeNew_ ? L"" : std::wstring(dlg->trip_.GetCompany().begin(), dlg->trip_.GetCompany().end())).c_str());
                makeLabel(6, L"Ort");
                dlg->edLocation_ = makeEdit(106, std::wstring(dlg->modeNew_ ? L"" : std::wstring(dlg->trip_.GetLocation().begin(), dlg->trip_.GetLocation().end())).c_str());
                makeLabel(7, L"Start");
                dlg->dateStart_ = CreateWindowExW(0, DATETIMEPICK_CLASSW, L"", WS_CHILD | WS_VISIBLE | DTS_SHORTDATEFORMAT, 100, y, 200, 20, hWnd, (HMENU)107, hInst, nullptr);
                SYSTEMTIME st{};
                if (!dlg->modeNew_)
                {
                    auto tt = std::chrono::system_clock::to_time_t(dlg->trip_.GetStartDate());
                    localtime_s(&st, &tt);
                }
                else
                {
                    GetLocalTime(&st);
                }
                DateTime_SetSystemtime(dlg->dateStart_, GDT_VALID, &st);
                y += 25;
                makeLabel(8, L"Ende");
                dlg->dateEnd_ = CreateWindowExW(0, DATETIMEPICK_CLASSW, L"", WS_CHILD | WS_VISIBLE | DTS_SHORTDATEFORMAT, 100, y, 200, 20, hWnd, (HMENU)108, hInst, nullptr);
                if (!dlg->modeNew_)
                {
                    st = {};
                    auto tt = std::chrono::system_clock::to_time_t(dlg->trip_.GetEndDate());
                    localtime_s(&st, &tt);
                }
                else
                {
                    GetLocalTime(&st);
                }
                DateTime_SetSystemtime(dlg->dateEnd_, GDT_VALID, &st);
                y += 25;
                makeLabel(9, L"Dauer");
                dlg->staticDuration_ = CreateWindowW(L"STATIC", L"", WS_CHILD | WS_VISIBLE, 100, y, 200, 20, hWnd, (HMENU)109, hInst, nullptr);
                auto computeDur = [&]()
                {
                    SYSTEMTIME s1{}, s2{};
                    DateTime_GetSystemtime(dlg->dateStart_, &s1);
                    DateTime_GetSystemtime(dlg->dateEnd_, &s2);
                    std::tm tm1{s1.wSecond, s1.wMinute, s1.wHour, s1.wDay, s1.wMonth - 1, s1.wYear - 1900};
                    std::tm tm2{s2.wSecond, s2.wMinute, s2.wHour, s2.wDay, s2.wMonth - 1, s2.wYear - 1900};
                    auto tp1 = std::chrono::system_clock::from_time_t(mktime(&tm1));
                    auto tp2 = std::chrono::system_clock::from_time_t(mktime(&tm2));
                    int dur = std::chrono::duration_cast<std::chrono::hours>(tp2 - tp1).count() / 24 + 1;
                    wchar_t buf[64];
                    wsprintfW(buf, L"%d Tage", dur);
                    SetWindowTextW(dlg->staticDuration_, buf);
                };
                computeDur();
                y += 30;
                CreateWindowW(L"BUTTON", L"OK", WS_CHILD | WS_VISIBLE, 100, y, 80, 25, hWnd, (HMENU)IDOK, hInst, nullptr);
                CreateWindowW(L"BUTTON", L"Cancel", WS_CHILD | WS_VISIBLE, 220, y, 80, 25, hWnd, (HMENU)IDCANCEL, hInst, nullptr);
                return 0;
            }
            case WM_COMMAND:
                if (LOWORD(wParam) == IDOK)
                {
                    wchar_t buf[256];
                    GetWindowTextW(dlg->edSd_, buf, 256);
                    std::wstring sd = buf;
                    GetWindowTextW(dlg->edPos_, buf, 256);
                    std::wstring pos = buf;
                    GetWindowTextW(dlg->edTitle_, buf, 256);
                    std::wstring title = buf;
                    GetWindowTextW(dlg->edMachine_, buf, 256);
                    std::wstring mach = buf;
                    GetWindowTextW(dlg->edCompany_, buf, 256);
                    std::wstring comp = buf;
                    GetWindowTextW(dlg->edLocation_, buf, 256);
                    std::wstring loc = buf;
                    SYSTEMTIME stStart, stEnd;
                    DateTime_GetSystemtime(dlg->dateStart_, &stStart);
                    DateTime_GetSystemtime(dlg->dateEnd_, &stEnd);
                    std::tm tmStart{stStart.wSecond, stStart.wMinute, stStart.wHour, stStart.wDay, stStart.wMonth - 1, stStart.wYear - 1900};
                    std::tm tmEnd{stEnd.wSecond, stEnd.wMinute, stEnd.wHour, stEnd.wDay, stEnd.wMonth - 1, stEnd.wYear - 1900};
                    auto start_tp = std::chrono::system_clock::from_time_t(mktime(&tmStart));
                    auto end_tp = std::chrono::system_clock::from_time_t(mktime(&tmEnd));
                    dlg->trip_ = ReiseManager::Core::Trip({std::string(sd.begin(), sd.end()), std::string(pos.begin(), pos.end())},
                                                          std::string(title.begin(), title.end()), std::string(mach.begin(), mach.end()),
                                                          std::string(comp.begin(), comp.end()), std::string(loc.begin(), loc.end()),
                                                          start_tp, end_tp);
                    dlg->dialogResult_ = IDOK;
                    PostQuitMessage(0);
                }
                else if (LOWORD(wParam) == IDCANCEL)
                {
                    dlg->dialogResult_ = IDCANCEL;
                    PostQuitMessage(0);
                }
                return 0;
            case WM_NOTIFY:
                if (((LPNMHDR)lParam)->idFrom == 107 || ((LPNMHDR)lParam)->idFrom == 108)
                {
                    SYSTEMTIME s1{}, s2{};
                    DateTime_GetSystemtime(dlg->dateStart_, &s1);
                    DateTime_GetSystemtime(dlg->dateEnd_, &s2);
                    std::tm tm1{s1.wSecond, s1.wMinute, s1.wHour, s1.wDay, s1.wMonth - 1, s1.wYear - 1900};
                    std::tm tm2{s2.wSecond, s2.wMinute, s2.wHour, s2.wDay, s2.wMonth - 1, s2.wYear - 1900};
                    auto tp1 = std::chrono::system_clock::from_time_t(mktime(&tm1));
                    auto tp2 = std::chrono::system_clock::from_time_t(mktime(&tm2));
                    int dur = std::chrono::duration_cast<std::chrono::hours>(tp2 - tp1).count() / 24 + 1;
                    wchar_t buf[64];
                    wsprintfW(buf, L"%d Tage", dur);
                    SetWindowTextW(dlg->staticDuration_, buf);
                }
                return 0;
            case WM_CLOSE:
                dlg->dialogResult_ = IDCANCEL;
                PostQuitMessage(0);
                return 0;
            }
            return DefWindowProcW(hWnd, msg, wParam, lParam);
        };
        wc.hInstance = hInstance;
        wc.lpszClassName = CLASS_NAME;
        wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
        wc.hbrBackground = (HBRUSH)(COLOR_BTNFACE + 1);
        RegisterClassExW(&wc);
        registered = true;
    }

    hwnd_ = CreateWindowExW(WS_EX_DLGMODALFRAME, CLASS_NAME, modeNew_ ? L"Neue Reise" : L"Reise bearbeiten",
                            WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, CW_USEDEFAULT, CW_USEDEFAULT, 330, 340, hParent, nullptr, hInstance, this);
    ShowWindow(hwnd_, SW_SHOW);
    UpdateWindow(hwnd_);

    MSG msg;
    while (GetMessageW(&msg, nullptr, 0, 0) > 0)
    {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }
    DestroyWindow(hwnd_);
    return dialogResult_;
#else
    (void)hInstance;
    (void)hParent;
    return IDCANCEL;
#endif
}

ReiseManager::Core::Trip TripDialog::GetTrip() const
{
    return trip_;
}
