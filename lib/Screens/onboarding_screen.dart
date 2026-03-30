import 'package:depi_gp/Screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "images/onboarding/Job_hunt_pana.png",
      "title": "Convenience & Speed",
      "desc":  "Find trusted professionals near you — fast, easy, and reliable.",
    },
    {
      "image": "images/onboarding/Electrician_rafiki.png",
      "title": "Trust & Quality",
      "desc":  "Book skilled experts with confidence — your home is in safe hands.",
    },
    {
      "image": "images/onboarding/Construction_worker_pana.png",
      "title": "Simplicity & Control",
      "desc":  "From problem to solution in a few taps — anytime, anywhere.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 50),

              GestureDetector(
                onTap: () {
                  _controller.animateToPage(
                    onboardingData.length - 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  "Skip",
                  style: GoogleFonts.montserrat(
                    color: AppColors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {

                    final data = onboardingData[index];

                    return Column(
                      children: [

                        Image.asset(
                          data["image"]!,
                          width: 350,
                          height: 350,
                          fit: BoxFit.cover,
                        ),

                        const SizedBox(height: 40),

                        Text(
                          data["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          data["desc"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentPage == index ? 10 : 6,
                    height: currentPage == index ? 10 : 6,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? AppColors.blue
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),


              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {

                    if (currentPage == onboardingData.length - 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Screens(),
                        ),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentPage == onboardingData.length - 1
                        ? "Start"
                        : "Next",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      //color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),


            ],
          ),
        ),
      ),
    );
  }
}