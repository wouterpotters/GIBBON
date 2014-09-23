function addHelpSearch

%% Make help files searchable

mfilePath = mfilename('fullpath');
gibbonPath=fileparts(fileparts(mfilePath));
gibbonHelpPath=fullfile(gibbonPath,'html');
builddocsearchdb(gibbonHelpPath);