% gitinstall - Install a Matlab package from a GitHub repository URL.
% Usage:
% gitinstall https://github.com/mhearne-usgs/mgitinstall [install|upgrade|delete]
% The first time this function is called, you will be prompted to select
% a folder where this and all other future packages will be installed.
function gitinstall(url,varargin)
    subcmd = 'install';
    supported = {'install','delete','upgrade'};
    if nargin == 2
       subcmd = varargin{1};
       if ~ismember(subcmd,supported)
           cmdlist = strjoin(supported,' ');
           fprintf('gitinstall subcommand must be one of: %s\n',cmdlist);
           return;
       end
    end
    %url = 'https://github.com/mhearne-usgs/impact'
    if ~strcmpi(url(end),'/')
        url = [url '/'];
    end
    parts = regexpi(url,'/','split');
    package = parts{end-1};
    zipurl = [url 'archive/master.zip'];
    tmpfile = tempname();
    urlwrite(zipurl,tmpfile);
    
    if ispc
        userdir= getenv('USERPROFILE'); 
    else 
        userdir= getenv('HOME');
    end
    configfile = fullfile(userdir,'.gitinstall','config.ini');
    if fileattrib(configfile)
        installpath = readconfig(configfile);
    else
        fprintf('You do not have a install path configured.\n');
        fprintf('I will present you with a list of writable folders\n');
        fprintf('already in your path.  Choose one:\n');
        pathfolders = regexpi(path(),':','split');
        wpaths = {};
        for i=1:length(pathfolders)
            fpath = pathfolders{i};
            if regexp(fpath,matlabroot)
                continue;
            end
            [status,message,messageid] = fileattrib(fpath);
            if ~status
                rmpath(fpath);
                continue;
            end
            if message.UserWrite
                if ~length(wpaths)
                    wpaths{end+1} = fpath;
                    continue;
                end
                found = 0;
                for j=1:length(wpaths)
                    wpath = wpaths{j};
                    match = regexp(fpath,wpath);
                    if length(match)
                        found = 1;
                        break;
                    end
                end
                if ~found
                    wpaths{end+1} = fpath;
                end
            end
        end
        for i=1:length(wpaths)
            wpath = wpaths{i};
            fprintf('%i) %s\n',i,wpath);
        end
        nresp = 0;
        prompt = sprintf('Enter the number of the path where %s should be saved: [1]',package);
        response = -1;
        while nresp < 3
            resp = input(prompt,'s');
            if isempty(resp)
                resp = '1';
            end
            resp = str2num(resp);
            if isempty(resp) || (resp < 1 && resp > length(wpaths))
                fprintf('Please choose a number from the above list\n');
                nresp = nresp + 1;
                continue;
            end
            response = resp;
            break;
        end
        if response == -1
            fprintf('You cannot seem to follow directions.  Quitting installer.\n');
            return;
        end
        installpath = wpaths{response};
        writeconfig(installpath,configfile);
    end
    packagepath = fullfile(installpath,package);
    a = dir(packagepath);
    b = isdir(packagepath);
    [s,r] = system(sprintf('ls -l %s',packagepath));
    switch subcmd
        case 'install'
            if ~isempty(a)
                fprintf('Package %s already exists.  Run "gitinstall %s upgrade" to force package download\n',package,url);
                return;
            else
                fprintf('Installing github package in %s.\n',packagepath);
            end
        case 'delete'
            if isempty(a)
                fprintf('No such package exists.  Returning.\n');
                return;
            end
            fprintf('Deleting %s from system and Matlab path\n',package);
            rmdir(packagepath,'s');
            w = warning ('off','all');
            rmpath(packagepath);
            warning(w);
            return;
        case 'upgrade'
            if isempty(a)
                fprintf('No such package exists on your system.  Installing.\n');
            else
                fprintf('Upgrading github package in %s.\n',packagepath);
            end
    end
    
    if isempty(a)
        [s,m,mid] = mkdir(packagepath);
        if ~s
            fprintf('Unable to create package folder.  Quitting.\n');
            return;
        end
    end
    unzip(tmpfile,packagepath);
    %the zip file actually unpacks into packagepath/package-master/
    %move that stuff up into packagepath
    actualpath = fullfile(packagepath,[package '-master']);
    a = dir(actualpath);
    matfiles = {};
    for i=3:length(a)
        actualfile = fullfile(actualpath,a(i).name);
        if ~isempty(regexp(actualfile,'.m$'))
            matfiles{end+1} = a(i).name;
        end
        movefile(actualfile,packagepath);
    end
    rmdir(actualpath);
    delete(tmpfile);
    w = warning ('off','all');
    if ~strcmpi(subcmd,'upgrade')
        addpath(packagepath);
    end
    warning(w);
    matlist = strjoin(matfiles,' ');
    fprintf('Installed functions: %s\n',matlist);
    
end

function writeconfig(installpath,configfile)
    [configfolder,configname,ext] = fileparts(configfile);
    a = dir(configfolder);
    if isempty(a)
        mkdir(configfolder);
    end
    fid = fopen(configfile,'wt');
    fprintf(fid,'gitinstall = %s\n',installpath);
    fclose(fid);
end

function gitpath = readconfig(configfile)
    fid = fopen(configfile,'rt');
    tline = fgetl(fid);
    fclose(fid);
    parts = regexpi(tline,'=','split');
    gitpath = strtrim(parts{2});
    return;
end