GetHwndCreationTime(hwnd)
{
	processId := GetWindowThreadProcessId(hwnd)

	try
	{
		hProcess := OpenProcess(processId)
		hwndCreationTime := GetCreationTime(hProcess)
		CloseHandle(hProcess)
	}
	catch e
    {
		showError(e)
    }

	return hwndCreationTime
}

GetWindowThreadProcessId(hwnd)
{
	VarSetCapacity(PROCESS_ID, 4, 0)
	DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", &PROCESS_ID)

	return NumGet(PROCESS_ID, "UInt")
}

OpenProcess(processId)
{
	static PROCESS_QUERY_LIMITED_INFORMATION := 0x1000

	if !(hProcess := DllCall("OpenProcess", "UInt", PROCESS_QUERY_LIMITED_INFORMATION, "Int", False, "UInt", processId))
		error("OpenProcess")

	return hProcess
}

GetCreationTime(hProcess)
{
	VarSetCapacity(CREATION_TIME, 8, 0)
	VarSetCapacity(IGNORE_ME, 8, 0)

	if !DllCall("GetProcessTimes", "Ptr", hProcess, "Ptr", &CREATION_TIME, "Ptr", &IGNORE_ME, "Ptr", &IGNORE_ME, "Ptr", &IGNORE_ME)
		error("GetProcessTimes")

	return FileTimeQuadPart(CREATION_TIME)
}

FileTimeQuadPart(ByRef FILETIME)
{
	dwLowDateTime := NumGet(FILETIME, 0, "UInt")
	dwHighDateTime := NumGet(FILETIME, 4, "UInt")

	VarSetCapacity(ULARGE_INTEGER, 8, 0)
	NumPut(dwLowDateTime, ULARGE_INTEGER, 0, "UInt")
	NumPut(dwHighDateTime, ULARGE_INTEGER, 4, "UInt")

	return NumGet(ULARGE_INTEGER, 0, "UInt64")
}

CloseHandle(hProcess)
{
	if !DllCall("CloseHandle", "Ptr", hProcess)
		error("CloseHandle")
}

GetSystemTimeAsFileTime()
{
	VarSetCapacity(SYSTEM_FILETIME, 8, 0)
	DllCall("GetSystemTimeAsFileTime", "Ptr", &SYSTEM_FILETIME)

	return FileTimeQuadPart(SYSTEM_FILETIME)
}

error(msg)
{
	throw Exception(Format("DllCall(""{}"") failed.`nA_LastError: {}", msg, A_LastError), -2)
}

showError(e)
{
	MsgBox % Format("
	(LTrim
		Exception on line {}.

		{}
	)", e.Line, e.Message)

	; Exit ; thread
	ExitApp ; delete this
}