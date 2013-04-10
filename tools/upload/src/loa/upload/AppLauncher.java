package loa.upload;

import com.jdotsoft.jarloader.JarClassLoader;

public class AppLauncher {
	public static void main(String[] args) {
		JarClassLoader jcl = new JarClassLoader();
		try {
			jcl.invokeMain("loa.upload.Upload", args);
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}
}
