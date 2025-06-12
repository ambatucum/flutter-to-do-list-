import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      body: Stack(
        children: [
          // Gradient utama
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFE5D0), // peach
                  Color(0xFFFFB199), // orange
                  Color(0xFFFFD6E0), // pink muda
                  Color(0xFFFFFFFF), // putih
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Soft spot pink/orange
          Positioned(
            left: -80,
            top: 80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFFB199).withOpacity(0.5),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          Positioned(
            right: -60,
            bottom: 60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFF8C94).withOpacity(0.4),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          // Tombol Login & Register kanan atas
          Positioned(
            top: 32,
            right: 48,
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9B1C1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFF9B1C1C)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF9B1C1C),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9B1C1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFF9B1C1C)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF9B1C1C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Panel dan konten utama
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child:
                  isWide
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),
                          // Lebarkan panel About Us
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                  horizontal: 48,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'About Us',
                                      style: GoogleFonts.merriweather(
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9B1C1C),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Dasker adalah aplikasi manajemen tugas yang membantu Anda mengatur, mengingat, dan menyelesaikan pekerjaan harian dengan mudah dan efisien. Cocok untuk pelajar, pekerja, maupun pribadi yang ingin lebih produktif.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        color: Color(0xFF22223B),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    SizedBox(
                                      width: 260,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => const SignUpScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF9B1C1C,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        child: const Text('Create Your List'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                          // Perbesar logo kanan
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 500,
                                child: Center(
                                  child: Image.asset(
                                    'assets/logo.png',
                                    height: 420,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(flex: 1),
                        ],
                      )
                      : SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 40,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Siapa Kami?',
                                    style: GoogleFonts.merriweather(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9B1C1C),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Dasker berasal dari perpaduan kata desk dan tasker, mencerminkan konsep manajemen tugas yang rapi, fokus, dan personal. Dirancang untuk para profesional, pelajar, dan siapa pun yang ingin mengelola hari-harinya dengan lebih terstruktur. Dasker membantu Anda menyusun daftar tugas secara efisien—mendukung produktivitas tanpa mengganggu kenyamanan visual. Satu tempat untuk setiap ide, tugas, dan rencana. Karena hidup yang rapi dimulai dari catatan kecil.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Color.fromRGBO(109, 20, 20, 1),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const SignUpScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF9B1C1C,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      child: const Text('Create Your List'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Image.asset(
                              'assets/logo.png',
                              height: 320,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
