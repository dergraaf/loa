package loa.upload;

import java.util.concurrent.TimeUnit;

public class TimeWatch {

	long start;
	long end;

	public static TimeWatch start() {
		return new TimeWatch();
	}

	private TimeWatch() {
		reset();
	}

	public TimeWatch reset() {
		start = System.nanoTime();
		end = start;
		return this;
	}
	
	public void stop() {
		end = System.nanoTime();
	}
	
	/**
	 * @return	Elapsed time in Nanoseconds
	 */
	public long getTime() {
		return (end - start);
	}

	public long getTime(TimeUnit unit) {
		return unit.convert(getTime(), TimeUnit.NANOSECONDS);
	}
}
