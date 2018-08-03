function [] = DA_bulk_downloader(file_ext,download_dir,download_list)
% DA_bulk_downloader.m
% This function takes a list of macrepo numbers as input, and downloads the selected file type for each digital archive item.
%%% Inputs:
% download_list - A one-column csv file with nothing but the macrepo numbers of the items to be downloaded.
% file_ext: '.tiff'    '.jp2'    '.jpeg' '.xml'
% download_dir: Path to a directory where the files are to be downloaded.

% Parameters
default_dir = 'D:/';
file_types_lookup = ...
    {'.tiff', 'OBJ';...
    '.jp2', 'JP2';...
    '.jpeg', 'TN';
    '.xml','MODS/download'};
fname1 = '';
pname1 = '';
pname2 = '';

%% Identify conditions where the GUI is needed:
if nargin <3 || (nargin==3 && (isempty(file_ext)==1 || isempty(download_dir)==1 || isempty(download_list)==1))

%% Build the GUI
f_ui = figure('Position',[100 100 350 100]);

%%% Filetype selector
h_list = uicontrol('style','list','max',10,...
     'min',1,'Position',[20 10 80 60],...
     'string',file_types_lookup(:,1));
h_list_txt = uicontrol('style','text','Position',[20 70 80 20],'String', 'Target Filetype');

%%% download list
dl_list = uicontrol('Style', 'pushbutton', 'String', 'Select Download List',...
        'Position', [110 50 150 20],...
        'Callback', ['[fname1, pname1] = uigetfile(''*.csv'',''Select download list'',''' default_dir '''); assignin(''caller'',''fname1'',fname1) ; assignin(''caller'',''pname1'',pname1)']); 

%%%
dl_dir = uicontrol('Style', 'pushbutton', 'String', 'Select Download Directory',...
        'Position', [110 10 150 20],...
        'Callback', ['[pname2] = uigetdir(''' default_dir ''',''Select download directory''); assignin(''caller'',''pname2'',pname2)']); 

go_button = uicontrol('Style', 'pushbutton', 'String', 'RUN!',...
        'Position', [280 40 25 25],...
        'Callback', 'set(gcbf, ''Tag'' , ''Running'')'); 
    
    waitfor(f_ui,'Tag','Running');
    download_list = [pname1 fname1];
    file_ext = file_types_lookup{get(h_list,'Value'),1};
    download_dir = pname2;
end

%% Cleanup. Build prefix.
% Ensure that extension is properly formatted:
if strcmp(file_ext(1),'.')~=1
    file_ext = ['.' file_ext];
end

if strcmp(download_dir(end),'\')~=1
    download_dir = [download_dir '\'];
end

dl_prefix = file_types_lookup{strcmp(file_ext,file_types_lookup(:,1))==1,2};
%% Run
%%% Open the download list 
fid = fopen(download_list);

eof = feof(fid);

while eof==0
    tline = fgetl(fid);
    commas = strfind(tline,',');
    if numel(commas)==1
    elseif numel(commas)==0
        commas(1) = length(tline)+1;
    end
    macrepo = tline(1:commas(1)-1);
% fname_out = [download_dir 'macrepo' macrepo file_ext];
fname_out = [download_dir macrepo file_ext]; %edited by JJB 20180802 - removed macrepo from title

% Format the download url differently depending on whether we want MODS or
% an image file
switch file_ext
    case '.xml'
        url = ['http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' macrepo '/datastream/' dl_prefix];
    otherwise
        url = ['http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' macrepo '/datastream/' dl_prefix '/' macrepo file_ext];
end

    try
        websave(fname_out,url);
    catch
    end
    eof = feof(fid);

end
fclose(fid);
