import 'package:ems/config/app_colors.dart';
import 'package:ems/views/login_signup/widgets/bottom_half_container.dart';
import 'package:ems/views/login_signup/widgets/social_button.dart';
import 'package:ems/views/login_signup/widgets/text_field.dart';
import 'package:flutter/material.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {

  bool isMale = true;
  bool isSignupScreen = true;
  bool isRememberMe = false;
  String title = 'Signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/event_banner.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 80, right: 20, left: 20),
                color: AppColors.containerShadow.withOpacity(0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: 'Welcome to ',
                          style: const TextStyle(
                            fontSize: 25,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: isSignupScreen ? 'EMS,' : 'Back,',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorBlue,
                              ),
                            ),
                          ]),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$title to continue',
                      style: const TextStyle(
                        letterSpacing: 1,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textColorBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          buildBottomHalfContainer(true,isSignupScreen),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: isSignupScreen? 180 : 220,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width - 40,
              height: isSignupScreen ? 380 : 280,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 15,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignupScreen = false;
                              title = 'Login';
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSignupScreen
                                      ? AppColors.textColor1
                                      : AppColors.activeColor,
                                ),
                              ),
                              if (!isSignupScreen)
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  height: 2,
                                  width: 55,
                                  color: Colors.orange,
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignupScreen = true;
                              title = 'Signup';
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                'SIGNUP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSignupScreen
                                      ? AppColors.activeColor
                                      : AppColors.textColor1,
                                ),
                              ),
                              if (isSignupScreen)
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  height: 2,
                                  width: 55,
                                  color: Colors.orange,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isSignupScreen) buildSignupSection(),
                    if (!isSignupScreen) buildLoginSection(),
                  ],
                ),
              ),
            ),
          ),
          buildBottomHalfContainer(false,isSignupScreen),
          Positioned(
            top: MediaQuery.of(context).size.height - 100,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Text(
                  isSignupScreen ? 'Or Signup with' : 'Or Login with',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: AppColors.textColorBlue,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildSocialButton(
                          'Facebook',
                          'assets/images/facebook_icon.png',
                          AppColors.facebookColor),
                      buildSocialButton(
                          'Google',
                          'assets/images/google_icon.png',
                          AppColors.googleColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSignupSection() {
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextField(
            Icons.account_circle_outlined,
            'User Name',
            false,
            false,
          ),
          buildTextField(
            Icons.email_outlined,
            'Email Address',
            false,
            true,
          ),
          buildTextField(
            Icons.lock_outline,
            'Password',
            true,
            false,
          ),
          const SizedBox(
            height: 10,
          ),
          if (isSignupScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMale = true;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textColor1,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          color: isMale ? AppColors.textColor2 : null,
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: isMale ? Colors.white : AppColors.iconColor,
                        ),
                      ),
                      Text(
                        'Male',
                        style: TextStyle(
                          color: AppColors.textColor1,
                          fontWeight:
                              isMale ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMale = false;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textColor1,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          color: isMale ? null : AppColors.textColor2,
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: isMale ? AppColors.iconColor : Colors.white,
                        ),
                      ),
                      Text(
                        'Female',
                        style: TextStyle(
                          color: AppColors.textColor1,
                          fontWeight:
                              isMale ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (isSignupScreen)
            Container(
              margin: const EdgeInsets.only(top: 20, right: 10, left: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                    text: 'By pressing submit you are agree to our ',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                    children: [
                      TextSpan(
                          text: 'terms & conditions.',
                          style: TextStyle(
                            color: Colors.blue,
                          ))
                    ]),
              ),
            ),
          if (!isSignupScreen) const Center(),
        ],
      ),
    );
  }

  Widget buildLoginSection(){
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      child: Column(
        children: [
          buildTextField(
            Icons.email_outlined,
            'example@gmail.com',
            false,
            true,
          ),
          buildTextField(
            Icons.lock_outline,
            '********',
            true,
            false,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isRememberMe,
                    activeColor: AppColors.textColor2,
                    onChanged: (value) {
                      setState(() {
                        isRememberMe = !isRememberMe;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isRememberMe = !isRememberMe;
                      });
                    },
                    child: const Text(
                      'Remember Me',
                      style: TextStyle(
                        color: AppColors.textColor1,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Forget Password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }



}
