
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toesor/modules/fb_login/cubti/states.dart';
import 'package:toesor/modules/googel_login/googel_login_screen.dart';
import 'package:toesor/modules/login_screen/cubit/cubit.dart';
import 'package:toesor/modules/login_screen/cubit/states.dart';
import 'package:toesor/modules/mapScreen/map_screen.dart';
import 'package:toesor/modules/profile_screen/profile_screen.dart';
import 'package:toesor/modules/sign_up/sign_up_screen.dart';
import 'package:toesor/shared/components/components.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:toesor/shared/constance/constant.dart';
import 'package:toesor/shared/network/local/sharedprefrance.dart';
import '../../shared/components/custom_snackpar.dart';
import '../../shared/style/colors.dart';
import '../fb_login/cubti/cubit.dart';
import '../resete_password/enter_email/enter_email.dart';
import '../resete_password/reset_password/reset_password.dart';

class LoginScreen extends StatelessWidget {
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  var formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocProvider<LoginCubit>(
      create:  (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit,LoginStates>(
        listener: (context, state) {
          if (state is SuccessLoginState){
           if(state.loginModel.code=='422'){
            ScaffoldMessenger.of(context)
                .showSnackBar(
              customSnackBar(
                message: 'Password Errata',
                title: 'Errore',
                type: ContentType.failure,
              ),

            );
          }
           if(state.loginModel.code=='432'){
             ScaffoldMessenger.of(context)
                 .showSnackBar(
               customSnackBar(
                 message: 'Account non trovato',
                 title: 'Errore',
                 type: ContentType.failure,
               ),

             );
           }

            if(state.loginModel.user?.status =='TRUE'){
              CacheHelper.saveData(
                key: 'token',
                value: state.loginModel.token.toString(),
              );
              sharedToken = state.loginModel.token.toString();
              //print(sharedToken.toString());
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                customSnackBar(
                  message: 'Welcome Back',
                  title: 'Success!',
                  type: ContentType.success,
                ),

              );
              navigateAndFinish(context,const ProfileScreen());
              clearController();

            }else if(state.loginModel.user?.status =='FALSE'){
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                customSnackBar(
                  message: 'Il tuo account è stato bloccato',
                  title: 'Errore',
                  type: ContentType.failure,
                ),

              );
            }
          }

        },
        builder: (context,state){
          LoginCubit cubit = LoginCubit.get(context);
          return Form(
            key: formKey,
            child: Scaffold(
              backgroundColor: kPrimaryColor,
              body: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/background.png',
                                ),
                                fit: BoxFit.cover,
                              )),
                        )),
                    Positioned(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                          ),
                        )),
                    Positioned(
                      child: Padding(
                        padding:EdgeInsets.symmetric(horizontal: size.width*0.15),
                        child: SingleChildScrollView(
                          physics:const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              sizeBoxStart(context),
                              Center(
                                child: SizedBox(
                                  width: size.width * 0.6,
                                  child: Image.asset(
                                    'assets/images/login_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height*0.04,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height*0.05,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Email :',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.height*0.03,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color:const Color(0xffFAF5EA),
                                    borderRadius: BorderRadius.circular(35)
                                ),
                                child: defaultFormField(
                                  context,
                                  controller: emailController,
                                  type: TextInputType.emailAddress,
                                  validate: (value){
                                    if (value!.isEmpty) {
                                      return 'Pleas enter your email address';
                                    }else if( !(isEmail(value.toString())))  {
                                      return 'the email is not valid';
                                    }
                                    return null;
                                  },
                                  label: '',

                                ),
                              ),
                              SizedBox(height: size.height*0.03,),
                              Row(
                                children: [
                                  Text(
                                    'Password :',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.height*0.02,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color:const Color(0xffFAF5EA),
                                    borderRadius: BorderRadius.circular(35)
                                ),
                                child: defaultFormField(
                                  context,
                                  isPassword: true,
                                  controller: passwordController,
                                  type: TextInputType.visiblePassword,
                                  validate: (value){
                                    if (value!.isEmpty) {
                                      return 'Pleas enter your Password';
                                    }
                                    return null;
                                  },
                                  label: '',
                                ),
                              ),
                              SizedBox(
                                height: size.height*0.04,
                              ),
                              ConditionalBuilder(
                                condition: state is ! LoadingLoginState,
                                builder: (context)=>defaultButton(
                                  context,
                                  background:const Color(0xff6A331D),
                                  function: (){
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    if(formKey.currentState!.validate()){
                                      cubit.loginUser(
                                        email: emailController.text.toString(),
                                        password: passwordController.text.toString(),
                                      );
                                    }
                                  },
                                  text: 'Login',
                                  rounder: BorderRadius.circular(35),
                                ),
                                fallback: (context)=>const Center(child: CircularProgressIndicator(color: Colors.orangeAccent,)),
                              ),
                              SvgPicture.asset('assets/icons/o.svg'),
                              BlocConsumer<FacebookLoginCubit,FacebookStates>(
                                listener: (context,state){
                                  FacebookLoginCubit facebookCubit = FacebookLoginCubit.get(context);
                                  if(state is SuccessFacebookState){
                                    facebookCubit.facebookLogin(
                                        token: facebookCubit.endToken.toString(),
                                        name: facebookCubit.userOpj["name"].toString(),
                                        email: facebookCubit.userOpj["email"].toString(),
                                        firstName: facebookCubit.firstName.toString(),
                                        lastName: facebookCubit.lastName.toString(),
                                        picture: facebookCubit.userOpj["picture"]["data"]["url"]).then((value) {
                                          navigateAndFinish(context, MapScreen());
                                    });
                                  }
                                },
                                builder: (context,state){
                                  FacebookLoginCubit facebookCubit = FacebookLoginCubit.get(context);
                                  return GestureDetector(
                                    onTap: (){
                                      facebookCubit.login();
                                      ///DO something
                                      //navigateTo(context, FaceBookLoginScreen());
                                    },
                                    child: Image.asset('assets/images/facebook.png'),
                                  );
                                },
                              ),
                              SizedBox(height: size.height*0.02,),
                              GestureDetector(
                                onTap: (){
                                  ///DO something
                                  navigateTo(context, GoogleLoginScreen());
                                },
                                child: Image.asset(
                                  'assets/images/googel.png',
                                ),
                              ),
                              SizedBox(height: size.height*0.01,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      navigateTo(context, ResetPasswordScreen());
                                    },
                                    child: Text(
                                      'reset Password',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontFamily: 'Comfortaa',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){

                                      navigateTo(context, SignUpScreen());
                                    },
                                    child: Text(
                                      'Sign Up ?',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontFamily: 'Comfortaa',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height*0.02,),
                              Center(
                                child: Image.asset(
                                  'assets/images/footer.png',
                                  fit: BoxFit.cover,
                                ),
                              ),

                              SizedBox(height: size.height*0.05,),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  void clearController(){
    emailController.clear();
    passwordController.clear();
  }
}
