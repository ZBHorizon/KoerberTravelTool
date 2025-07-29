#pragma once
#include <string>
namespace ReiseManager::Core {

/**
 * Append a log entry to the ReiseManager log file.
 *
 * @param level   Log level string (e.g. "INFO", "ERROR").
 * @param message Message text to record.
 */
void Log(const std::string& level, const std::string& message);

} // namespace ReiseManager::Core
