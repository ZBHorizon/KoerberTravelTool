#pragma once
#include <string>
namespace TravelManager::Core {

/**
 * Append a log entry to the TravelManager log file.
 *
 * @param level   Log level string (e.g. "INFO", "ERROR").
 * @param message Message text to record.
 */
void Log(const std::string& level, const std::string& message);

} // namespace TravelManager::Core
