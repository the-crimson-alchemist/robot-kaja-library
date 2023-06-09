// build with : dmd kajaTest.d -L../lib-d/kajaLibD.so -ofKaja.exe
import std.file : readText;
import std.stdio : write, writeln;
import std.conv : to;
import core.thread : Thread, msecs;

///////////////////////////
// Load extern functions //
///////////////////////////
extern(C) bool innit(string city, string mainScript);
extern(C) bool loadScript(string newScript);
extern(C) bool doSomething();
extern(C) string getStatusMessage();
extern(C) ushort[] getMapDimensions();
extern(C) ushort[] getKaja();
extern(C) ushort[] getHome();
extern(C) ushort[][] getFlags();
extern(C) ushort[][] getSolidWalls();
extern(C) ushort[][] getBreakableWalls();
extern(C) void changeSolidWall(ushort x,ushort y);
extern(C) void changeBreakableWall(ushort x,ushort y);
extern(C) void relocateHome(ushort x,ushort y);
extern(C) void addFlag(ushort x,ushort y);
extern(C) void substractFlag(ushort x,ushort y);

////////////////////////
// Set some variables //
////////////////////////

static ushort[] mapDimensions;

//////////
// Test //
//////////

// call stuff //
void main(){
	// innicialize //
	string mesto = readText("../test-scripts/map1.txt");
	string mainScript = readText("../test-scripts/test-basics.txt");
	string vpravo = readText("../test-scripts/vpravo.txt");
	write(mesto);

	// catch errors
	if (!innit(mesto,mainScript)){
		writeln(getStatusMessage());
		return;
	}

	// load additional script
	loadScript(vpravo);

	mapDimensions = getMapDimensions();

	// run until end of script
	do {
		// write current state
		writeln();
		showMap();
		// sleep for a while
		Thread.sleep(msecs(200));
	} while (doSomething());
	// write why exit
	writeln(getStatusMessage());

}

// show current state //
void showMap(){
	string[][] toShow;

	// innitial nothing
	for (ushort y = 0; y < mapDimensions[1]; y++){
		string[] newPart = [];
		for (ushort x = 0; x < mapDimensions[0]; x++)
			newPart ~= "..";
		toShow ~= newPart;
	}

	// flags
	foreach (ushort[] flag; getFlags()){
		// add only two digits or FL
		string flagString = to!string(flag[2]);

		if (flagString.length == 2)
			toShow[flag[1]][flag[0]] = "\x1b[35m"~flagString~"\x1b[37m";
		else if (flagString.length == 1)
			toShow[flag[1]][flag[0]] = "\x1b[35m0"~flagString~"\x1b[37m";
		else
			toShow[flag[1]][flag[0]] = "\x1b[35m~~\x1b[37m";
	}

	// walls
	foreach (ushort[] wall; getSolidWalls())
		toShow[wall[1]][wall[0]] = "\x1b[31m██\x1b[37m";
	foreach (ushort[] wall; getBreakableWalls())
		toShow[wall[1]][wall[0]] = "\x1b[33m▒▒\x1b[37m";

	// home
	ushort[] home = getHome();
	if (home.length == 2)
		toShow[home[1]][home[0]] = "\x1b[32m╠╣\x1b[37m";

	// kaja
	ushort[] kaja = getKaja();
	switch (kaja[2]){
		case 1:
			toShow[kaja[1]][kaja[0]] = "\x1b[36m/\\\x1b[37m";
			break;
		case 2:
			toShow[kaja[1]][kaja[0]] = "\x1b[36m=>\x1b[37m";
			break;
		case 3:
			toShow[kaja[1]][kaja[0]] = "\x1b[36m\\/\x1b[37m";
			break;
		default:
			toShow[kaja[1]][kaja[0]] = "\x1b[36m<=\x1b[37m";
	}

	// draw
	string actualDraw = "";
	for (ushort i = 0; i < toShow.length; i++){
		for (ushort j = 0; j < toShow[0].length; j++)
			actualDraw ~= toShow[i][j];
		actualDraw ~= "\n";
	}

	write(actualDraw);

}
