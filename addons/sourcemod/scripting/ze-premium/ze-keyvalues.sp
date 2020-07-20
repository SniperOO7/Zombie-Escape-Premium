public ReadFileFolder(char[] path)
{
	Handle dirh = INVALID_HANDLE;
	char buffer[256];
	char tmp_path[256];
	FileType type = FileType_Unknown;
	int len;
	
	len = strlen(path);
	if (path[len-1] == '\n')
		path[--len] = '\0';

	TrimString(path);
	
	if(DirExists(path))
	{
		dirh = OpenDirectory(path);
		while(ReadDirEntry(dirh,buffer,sizeof(buffer),type))
		{
			len = strlen(buffer);
			if (buffer[len-1] == '\n')
				buffer[--len] = '\0';

			TrimString(buffer);

			if (!StrEqual(buffer,"",false) && !StrEqual(buffer,".",false) && !StrEqual(buffer,"..",false))
			{
				strcopy(tmp_path,255,path);
				StrCat(tmp_path,255,"/");
				StrCat(tmp_path,255,buffer);
				if(type == FileType_File)
				{
					StartToDownload(tmp_path);
				}
				else
				{
					ReadFileFolder(tmp_path);
				}
			}
		}
	}
	else
	{
		StartToDownload(path);
	}
	if(dirh != INVALID_HANDLE)
	{
		CloseHandle(dirh);
	}
}

public DownloadFiles(){
	char file[256];
	BuildPath(Path_SM, file, 255, "configs/ze_premium-download.ini");
	Handle fileh = OpenFile(file, "r");
	char buffer[256];
	int len;
	
	if(fileh == INVALID_HANDLE) return;
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if(!StrEqual(buffer,"",false))
		{
			ReadFileFolder(buffer);
		}
		
		if (IsEndOfFile(fileh))
			break;
	}
	if(fileh != INVALID_HANDLE){
		CloseHandle(fileh);
	}
}

public void StartToDownload(char[] buffer)
{
	int len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	TrimString(buffer);
	if(len >= 2 && buffer[0] == '/' && buffer[1] == '/')
	{
		//Comment
	}
	else if (!StrEqual(buffer,"",false) && FileExists(buffer))
	{
		AddFileToDownloadsTable(buffer);
	}
}