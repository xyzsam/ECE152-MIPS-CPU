/** 
 * Software implementation of the Booth multiplication algorithm.
 */
public class Booth {

     public static void main(String[] args) {
        if (args.length != 2) {
             System.out.println("Wrong arguments.");
             return;
        }
        int m = Integer.parseInt(args[0]);
        int x = Integer.parseInt(args[1]);
        System.out.println(mult(m, x));
     }

     public static int mult(int m, int x) {
        int sum = 0;
        int tempM = m;
        int tempX = (x << 1); // shift right 1 to add implicit zero
        for (int counter = 0; counter < 16; counter ++) {
                int bits = tempX & 0x3;
                if (bits == 2)
                     sum -= tempM;
                else if (bits == 1)
                     sum += tempM;
                tempM = tempM << 1;
                tempX = tempX >> 1;
        }
        return sum;
     }
}
