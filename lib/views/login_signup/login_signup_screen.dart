import 'package:ems/config/app_colors.dart';
import 'package:ems/controller/auth_contoller.dart';
import 'package:ems/widgets/bottom_half_container.dart';
import 'package:ems/widgets/social_button.dart';
import 'package:ems/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isSignupScreen = false;
  bool isRememberMe = false;
  String title = 'Signup';

  bool isPassword = true;
  bool isLoginPassword = true;
  bool isConfirmPassword = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController emailLoginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController forgetPasswordController = TextEditingController();

  late AuthController authController;

  @override
  void initState() {
    super.initState();

    authController = Get.put(AuthController());
  }

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
          buildBottomHalfContainer(
            showShadow: true,
            isSignupScreen: isSignupScreen,
            formKey: formKey,
            authController: authController,
            emailController: emailController,
            emailLoginController: emailLoginController,
            passwordController: passwordController,
            passwordLoginController: passwordLoginController,
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: isSignupScreen ? 180 : 220,
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
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          if (isSignupScreen) buildSignupSection(),
                          if (!isSignupScreen) buildLoginSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          buildBottomHalfContainer(
            showShadow: false,
            isSignupScreen: isSignupScreen,
            formKey: formKey,
            authController: authController,
            emailController: emailController,
            emailLoginController: emailLoginController,
            passwordController: passwordController,
            passwordLoginController: passwordLoginController,
          ),
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
                        title: 'Facebook',
                        image: 'assets/images/facebook_icon.png',
                        backgroundColor: AppColors.facebookColor,
                        isGoogle: false,
                        authController: authController,
                        isSignupScreen: isSignupScreen,
                      ),
                      buildSocialButton(
                        title: 'Google',
                        image: 'assets/images/google_icon.png',
                        backgroundColor: AppColors.googleColor,
                        isGoogle: true,
                        authController: authController,
                        isSignupScreen: isSignupScreen,
                      ),
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
        top: 20,
        bottom: 30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextField(
            iconData: Icons.email_outlined,
            hintText: 'Email Address',
            isPassword: false,
            textInputType: TextInputType.emailAddress,
            controller: emailController,
            validator: (String input) {
              if (input.isEmpty) {
                Get.snackbar(
                  'Warning',
                  'Email is required!',colorText: Colors.blue
                );
                return '';
              } else if (!input.contains('@')) {
                Get.snackbar(
                  'Warning',
                  'Email is invalid!',colorText: Colors.blue
                );
                return '';
              }
            },
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                controller: passwordController,
                validator: (input) {
                  if (input!.isEmpty) {
                    Get.snackbar(
                        'Warning',
                        'Password is required!',colorText: Colors.blue
                    );
                    return '';
                  } else if (input.length < 6) {
                    Get.snackbar(
                        'Warning',
                        'Password must be 6 digit or more!',colorText: Colors.blue
                    );
                    return '';
                  }
                  return null;
                },
                obscureText: isPassword,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.iconColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPassword ? Icons.visibility_off : Icons.visibility ,
                      color: AppColors.iconColor,
                    ),
                    onPressed: () {

                      setState((){
                        isPassword = !isPassword;
                      });

                    },
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textColor1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textColorBlue,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.redAccent,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.redAccent,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textColor1,
                  ),
                ),
              ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: confirmPasswordController,
              validator: (input) {
                if (input!.isEmpty) {
                  Get.snackbar(
                      'Warning',
                      'Confirm Password is required!',colorText: Colors.blue
                  );
                  return '';
                } else if (input != passwordController.text.trim()) {
                  Get.snackbar(
                      'Warning',
                      'Password not match try again!',colorText: Colors.blue
                  );
                  return '';
                }
                return null;
              },
              obscureText: isConfirmPassword,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.iconColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPassword ? Icons.visibility_off : Icons.visibility ,
                    color: AppColors.iconColor,
                  ),
                  onPressed: () {

                    setState((){
                      isConfirmPassword = !isConfirmPassword;
                    });

                  },
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.textColor1,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.textColorBlue,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                contentPadding: const EdgeInsets.all(15),
                hintText: 'Confirm Password',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor1,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          /*if (isSignupScreen)
            */
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

  Widget buildLoginSection() {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        bottom: 30,
      ),
      child: Column(
        children: [
          buildTextField(
            iconData: Icons.email_outlined,
            hintText: 'example@gmail.com',
            isPassword: false,
            textInputType: TextInputType.emailAddress,
            controller: emailLoginController,
            validator: (String input) {
              if (input.isEmpty) {
                Get.snackbar(
                  'Warning',
                  'Email is required!',colorText: Colors.blue
                );
                return '';
              } else if (!input.contains('@')) {
                Get.snackbar(
                  'Warning',
                  'Email is invalid!',colorText: Colors.blue
                );
                return '';
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: passwordLoginController,
              validator: (input) {
                if (input!.isEmpty) {
                  Get.snackbar(
                      'Warning',
                      'Password is required!',colorText: Colors.blue
                  );
                  return '';
                } else if (input.length < 6) {
                  Get.snackbar(
                      'Warning',
                      'Password must be 6 digit or more!',colorText: Colors.blue
                  );
                  return '';
                }
                return null;
              },
              obscureText: isLoginPassword,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.iconColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isLoginPassword ? Icons.visibility_off : Icons.visibility ,
                    color: AppColors.iconColor,
                  ),
                  onPressed: () {

                    setState((){
                      isLoginPassword = !isLoginPassword;
                    });

                  },
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.textColor1,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.textColorBlue,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                contentPadding: const EdgeInsets.all(15),
                hintText: '***********',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor1,
                ),
              ),
            ),
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
                    onTap: () {
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
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Forget Password ?',
                    content: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: buildTextField(
                            iconData: Icons.email_outlined,
                            hintText: 'Enter your email here',
                            isPassword: false,
                            textInputType: TextInputType.emailAddress,
                            controller: forgetPasswordController,
                            validator: (String input) {
                              if (input.isEmpty) {
                                Get.snackbar(
                                  'Warning',
                                  'Email is required!',colorText: Colors.blue
                                );
                                return '';
                              } else if (!input.contains('@')) {
                                Get.snackbar(
                                  'Warning',
                                  'Email is invalid!',colorText: Colors.blue
                                );
                                return '';
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: MaterialButton(
                            onPressed: () {
                              authController.forgetPassword(
                                email: forgetPasswordController.text.trim(),
                              );
                            },
                            minWidth: MediaQuery.of(context).size.width - 30,
                            color: Colors.blue,
                            child: const Text(
                              'Send',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
