import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.Instrumentation;
import java.security.ProtectionDomain;

public class FeatherFix522 implements ClassFileTransformer {
    public static void premain(String agentArgs, Instrumentation inst) {
        inst.addTransformer(new FeatherFix522());
        System.out.println("[FeatherFix522] Multi-Version Agent initialized!");
    }

    @Override
    public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined,
                            ProtectionDomain protectionDomain, byte[] classfileBuffer) {
        if (className != null && className.startsWith("net/digitalingot/feather/")) {
            // Check if class contains the dead webapp host string
            String classStr = new String(classfileBuffer, java.nio.charset.StandardCharsets.ISO_8859_1);
            if (classStr.contains("mc-webapp.feathermc.com")) {
                byte[] bytes = classfileBuffer.clone();
                int count = 0;
                for (int i = 0; i < bytes.length - 3; i++) {
                    // Find opcode: ldc #6 (12 06) followed by areturn (b0)
                    // and change constant index to #4 (beta.mc-webapp.feathermc.com)
                    if (bytes[i] == 0x12 && bytes[i + 1] == 0x06 && (bytes[i + 2] & 0xFF) == 0xB0) {
                        bytes[i + 1] = 0x04;
                        count++;
                    }
                }
                if (count > 0) {
                    System.out.println("[FeatherFix522] Successfully patched " + className + " (" + count + " occurrences) -> beta.mc-webapp!");
                    return bytes;
                }
            }
        }
        return null;
    }
}
