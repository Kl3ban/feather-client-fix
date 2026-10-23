import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.Instrumentation;
import java.nio.charset.StandardCharsets;
import java.security.ProtectionDomain;
import java.util.ArrayList;
import java.util.List;

public class FeatherFix522 implements ClassFileTransformer {
    public static void premain(String agentArgs, Instrumentation inst) {
        inst.addTransformer(new FeatherFix522());
        System.out.println("[FeatherFix522] Universal Agent initialized for all MC versions (Forge & Fabric)!");
    }

    @Override
    public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined,
                            ProtectionDomain protectionDomain, byte[] classfileBuffer) {
        if (classfileBuffer == null || classfileBuffer.length < 10) {
            return null;
        }

        String quickCheck = new String(classfileBuffer, StandardCharsets.ISO_8859_1);
        if (!quickCheck.contains("mc-webapp.feathermc.com")) {
            return null;
        }

        byte[] patched = patchClass(classfileBuffer);
        if (patched != null) {
            System.out.println("[FeatherFix522] Successfully patched " + className + " -> beta.mc-webapp!");
            return patched;
        }

        return null;
    }

    private static byte[] patchClass(byte[] data) {
        try {
            ByteArrayInputStream bais = new ByteArrayInputStream(data);
            DataInputStream dis = new DataInputStream(bais);
            int magic = dis.readInt();
            if (magic != 0xCAFEBABE) return null;
            dis.readUnsignedShort();
            dis.readUnsignedShort();
            int cpCount = dis.readUnsignedShort();

            class Replacement {
                int lenOffset;
                int oldLen;
                byte[] newBytes;
                Replacement(int o, int ol, byte[] nb) {
                    lenOffset = o; oldLen = ol; newBytes = nb;
                }
            }
            List<Replacement> reps = new ArrayList<Replacement>();

            for (int i = 1; i < cpCount; i++) {
                int tag = dis.readUnsignedByte();
                switch (tag) {
                    case 1:
                        int len = dis.readUnsignedShort();
                        byte[] strBytes = new byte[len];
                        dis.readFully(strBytes);
                        String s = new String(strBytes, StandardCharsets.UTF_8);
                        if (s.equals("https://mc-webapp.feathermc.com/")) {
                            int currentPos = data.length - bais.available();
                            reps.add(new Replacement(currentPos - len - 2, len, "https://beta.mc-webapp.feathermc.com/".getBytes(StandardCharsets.UTF_8)));
                        } else if (s.equals("mc-webapp.feathermc.com")) {
                            int currentPos = data.length - bais.available();
                            reps.add(new Replacement(currentPos - len - 2, len, "beta.mc-webapp.feathermc.com".getBytes(StandardCharsets.UTF_8)));
                        }
                        break;
                    case 3: case 4: case 9: case 10: case 11: case 12: case 18:
                        dis.skipBytes(4);
                        break;
                    case 5: case 6:
                        dis.skipBytes(8);
                        i++;
                        break;
                    case 7: case 8: case 16: case 19: case 20:
                        dis.skipBytes(2);
                        break;
                    case 15:
                        dis.skipBytes(3);
                        break;
                    default:
                        return null;
                }
            }

            if (reps.isEmpty()) return null;

            ByteArrayOutputStream out = new ByteArrayOutputStream(data.length + 64);
            int lastCopied = 0;
            for (Replacement r : reps) {
                out.write(data, lastCopied, r.lenOffset - lastCopied);
                out.write((r.newBytes.length >> 8) & 0xFF);
                out.write(r.newBytes.length & 0xFF);
                out.write(r.newBytes);
                lastCopied = r.lenOffset + 2 + r.oldLen;
            }
            out.write(data, lastCopied, data.length - lastCopied);

            return out.toByteArray();
        } catch (Exception e) {
            return null;
        }
    }
}
