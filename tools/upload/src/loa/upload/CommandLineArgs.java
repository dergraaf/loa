package loa.upload;

import java.util.ArrayList;
import java.util.List;

import com.beust.jcommander.Parameter;

public class CommandLineArgs {
	@Parameter(names={"-p", "--port"}, description="Serial Port")
	public String port;
	
	@Parameter(names={"-b", "--baud"}, description="Baudrate")
	public Integer baudrate = 115200;
	
	@Parameter(names={"-v", "--verbose"}, description="Display debug messages")
	public boolean verbose = false;
	
	@Parameter(names={"-h", "--help"}, description="Display this help and exit")
	boolean help = false;
	
	@Parameter(description = "FILE")
	public List<String> files = new ArrayList<String>();
}
