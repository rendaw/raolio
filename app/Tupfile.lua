local LinkFlags = ' -pthread -lboost_system -lboost_filesystem -lboost_regex -lev'

local SharedObjects = Define.Objects
{
	Sources = Item()
		+ 'shared.cxx'
		+ 'core.cxx'
		+ 'hash.cxx'
		+ 'md5.c'
		+ 'network.cxx'
}

local SharedClientObjects = Define.Objects
{
	Sources = Item()
		+ 'clientcore.cxx'
}

local PackageDependencies =
	(tup.getconfig 'PLATFORM' == 'arch64' and "'boost>=1.54.0-3', 'boost-libs>=1.54.0-3', 'libev>=4.15-1'" or '') ..
	(tup.getconfig 'PLATFORM' == 'ubuntu' and 'libboost-all-dev (>= 1.53.0-6), libev4 (>= 1.4.11-1)' or '')

if tup.getconfig 'BUILDGUI' ~= 'false'
then
	local raolioguiMocOutputs = Define.Raw
	{
		Inputs = Item 'qtaux.h',
		Outputs = Item 'moc_qtaux.cxx',
		Command = 'moc qtaux.h > moc_qtaux.cxx'
	}

	raoliogui = Define.Executable
	{
		Name = 'raoliogui',
		Sources = Item() + 'gui.cxx' + raolioguiMocOutputs,
		Objects = SharedObjects + SharedClientObjects,
		BuildFlags = tup.getconfig 'GUIBUILDFLAGS',
		LinkFlags = LinkFlags .. ' ' .. tup.getconfig 'GUILINKFLAGS' .. ' -lvlc'
	}

	local PackageDependencies = PackageDependencies ..
		(tup.getconfig 'PLATFORM' == 'arch64' and ", 'qt5-base>=5.1.1-1', 'vlc>=2.1.0-3'" or '') ..
		(tup.getconfig 'PLATFORM' == 'ubuntu' and 'libboost-all-dev (>= 1.53.0-6), libev4 (>= 1.4.11-1)' or '')
	Package = Define.Package
	{
		Name = 'raoliogui',
		Dependencies = PackageDependencies,
		Executables = raoliogui,
		Resources = Item '*.png',
		ArchLicenseStyle = 'LGPL',
		DebianSection = 'sound',
		Licenses = Item '../license-raolio.txt'
	}
end

if tup.getconfig 'BUILDSERVER'
then
	raolioserver = Define.Executable
	{
		Name = 'raolioserver',
		Sources = Item() + 'server.cxx',
		Objects = SharedObjects,
		LinkFlags = LinkFlags
	}

	raolioremote = Define.Executable
	{
		Name = 'raolioremote',
		Sources = Item() + 'remote.cxx',
		Objects = SharedObjects,
		LinkFlags = LinkFlags
	}

	Package = Define.Package
	{
		Name = 'raolioserver',
		Dependencies = PackageDependencies,
		Executables = raolioserver + raolioremote,
		ArchLicenseStyle = 'LGPL3',
		DebianSection = 'sound',
		Licenses = Item '../license-raolio.txt'
	}
end

if tup.getconfig 'BUILDCLI'
then
	raoliocli = Define.Executable
	{
		Name = 'raoliocli',
		Sources = Item() + 'cli.cxx',
		Objects = SharedObjects + SharedClientObjects,
		LinkFlags = LinkFlags .. ' -lreadline -lvlc'
	}

	local PackageDependencies = PackageDependencies ..
		(tup.getconfig 'PLATFORM' == 'arch64' and ", 'readline>=6.2.004-1'" or '') ..
		(tup.getconfig 'PLATFORM' == 'ubuntu' and '' or '')
	Package = Define.Package
	{
		Name = 'raoliocli',
		Dependencies = PackageDependencies,
		Executables = raoliocli,
		ArchLicenseStyle = 'LGPL',
		DebianSection = 'sound',
		Licenses = Item '../license-raolio.txt'
	}
end
