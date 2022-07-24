import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toesor/models/get_all_routes_model.dart';
import 'package:toesor/modules/gioca_screen/gioca_screen.dart';
import 'package:toesor/modules/mapScreen/cubit/cubit.dart';
import 'package:toesor/modules/mapScreen/cubit/states.dart';
import '../../shared/components/colors_dots/colors_dots_screen.dart';
import '../../shared/components/components.dart';
import '../../shared/components/navigationbar/navigationbar.dart';
import '../../shared/constance/logout.dart';
import '../../shared/style/colors.dart';



class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
    Size size = MediaQuery.of(context).size;
    if (MapScreenCubit.get(context).position != null) {

      print(' lat: ${MapScreenCubit.get(context).position!.latitude} , long: ${MapScreenCubit.get(context).position!.longitude}');
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kAppbarColor,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.01),
              child: IconButton(
                onPressed: () {
                  signOut(context);
                },
                icon: Icon(
                  Icons.logout,
                  size: 33.sp,
                  color: const Color(0xffEEDEBA),
                ),
              ),
            ),
          ],
          leading: GestureDetector(
            onTap: () => scaffoldKey.currentState!.openDrawer(),
            child: Icon(
              Icons.menu,
              size: 33.sp,
              color: const Color(0xffEEDEBA),
            ),
          ),
        ),
        body: Scaffold(
          drawer: const NavigationDrawerScreen(),
          key: scaffoldKey,
          body: Column(
            children: [
              Container(
                height: size.height * 0.075,
                decoration: const BoxDecoration(
                  color: Color(0xffEEDEBA),
                  borderRadius: BorderRadius.only(),
                ),
                child: TabBar(
                    indicatorColor: Colors.transparent,
                    unselectedLabelColor: const Color(0xffD8C9A8),
                    indicator: const BoxDecoration(
                      color: Color(0xff6A331D),
                      borderRadius: BorderRadius.only(
                          // topRight: Radius.circular(70),
                          // bottomRight: Radius.circular(10),
                          ),
                    ),
                    labelStyle: TextStyle(
                        fontSize: 29.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Comfortaa'),
                    tabs: [
                      Tab(
                        child: Container(
                          height: size.height,
                          width: size.width / 2,
                          child: Center(
                            child: Text(
                              'MAPPA',
                              style: TextStyle(
                                  fontSize: 29.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Comfortaa'),
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          height: size.height,
                          width: size.width,
                          child: Center(
                            child: Text(
                              'ELENCO',
                              style: TextStyle(
                                  fontSize: 29.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Comfortaa'),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),

              /// Tabs
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ///First Tab
                    BlocConsumer<MapScreenCubit,MapScreenStates>(
                      listener: (context,state){
                        if(state is SuccessTabTwoMapScreenState){
                          if(state.data.isNotEmpty){
                            MapScreenCubit.get(context).getMarkers(context);
                          }
                        }
                        if(state is ChangePositionLocationMapScreen){
                          if (MapScreenCubit.get(context).position != null) {
                            MapScreenCubit.get(context).myCurrentMarker(context);
                            //Send LATLNG With 2 Secends
                            Timer.periodic(
                              const Duration(seconds: 2),
                                  (timer) => MapScreenCubit.get(context).sendLatLong(
                                lat: MapScreenCubit.get(context).position!.latitude,
                                lon: MapScreenCubit.get(context).position!.longitude,
                              ),
                            );
                          }else{
                            
                          }
                        }

                      },
                      builder: (context,state){
                        return Stack(children: [
                          MapScreenCubit.get(context).position != null
                              ? GoogleMap(
                              mapType: MapType.terrain,
                              markers: MapScreenCubit.get(context).markers,
                              initialCameraPosition: MapScreenCubit.get(context).position != null ?
                              CameraPosition(
                                bearing: 0.0,
                                target: LatLng(MapScreenCubit.get(context).position!.latitude, MapScreenCubit.get(context).position!.longitude),
                                tilt: 0.0,
                                zoom: 18.0,
                              ) : const CameraPosition(
                                bearing: 0.0,
                                target: LatLng(30.5234851, 30.532179),
                                tilt: 0.0,
                                zoom: 17.0,
                              ),
                          )
                              : const Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,

                            ),
                          ),
                        ]);
                      }
                    ),
                    ///second Tab
                    BlocConsumer<MapScreenCubit,MapScreenStates>(
                      listener: (context, state) {
                        if(state is  LoadingTabTwoMapScreenState){
                         const Center(
                            child:  CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          );
                        }
                      },
                     builder: (context ,state){

                        MapScreenCubit cubit = MapScreenCubit.get(context);
                        return  ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) => buildSecondTabMAP(
                              context,
                               cubit.data,
                            index,
                            index %2 ==0 ? true : false

                          ),
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 0,
                          ),
                           itemCount: MapScreenCubit.get(context).data.length,
                        );
                     },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  ///buildSecondTab Screen in tab bar
  Widget buildSecondTabMAP(context,List<DataModel> data,int index, bool isEven)=>GestureDetector(
    onTap: (){
      bottomSheet(
        context,
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.27,
          decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              )),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.015,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      Text(
                        data[index].Roue_Name.toString(),
                        style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Comfortaa'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          data[index].length.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Comfortaa'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Row(
                            children: const [
                              ColorDot(),
                              ColorDot(
                                isSelected: false,
                              ),
                              ColorDot(
                                isSelected: false,
                              ),
                              ColorDot(
                                isSelected: false,
                              ),
                              ColorDot(
                                isSelected: false,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Lunghezza (km)',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Comfortaa'),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          data[index].duration.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Comfortaa'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Row(
                            children: const [
                              ColorDot(),
                              ColorDot(),
                              ColorDot(
                                isSelected: false,
                              ),
                              ColorDot(
                                isSelected: false,
                              ),
                              ColorDot(
                                isSelected: false,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Tempo medio',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Comfortaa'),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '3',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Comfortaa'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Row(
                            children: const [
                              ColorDot(),
                              ColorDot(
                                isSelected: false,
                              ),
                              ColorDot(
                                isSelected: false,
                              ),
                              ColorDot(
                                isSelected: false,
                              ),
                              ColorDot(
                                isSelected: false,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Numero tappe',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Comfortaa'),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
                  child: Column(
                    children: [
                      Text(
                        'DESCRIZIONE \n${data[index].descr.toString()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Comfortaa',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.38,
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    color: const Color(0XFF5BA57B),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: (){
                        navigateTo(context, GiocaScreen());
                      },
                      child: Text(
                        'SCEGLI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Comfortaa',
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    child: Container(
      color: isEven ? Colors.white :const Color(0xffD8C194),
      child: Padding(
        padding: EdgeInsets.only(
          top:MediaQuery.of(context).size.height*0.02,
        ),
        child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.only( left:MediaQuery.of(context).size.width*0.03,),
              child: Row(
                children: [
                  BlocProvider(
                    create: (BuildContext context)=>MapScreenCubit(),
                    child: BlocConsumer<MapScreenCubit,MapScreenStates>(
                      listener: (context, state) {},
                      builder:(context,state){
                        return Text(
                          '${data[index].length} Km ',
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Comfortaa'
                          ),
                        );
                        /*
                          '${MapScreenCubit.get(context).calculateDistance(
                              MapScreenCubit.get(context).position!.latitude.toString(),
                              MapScreenCubit.get(context).position!.longitude.toString(),
                              '${data[index].routeLat}',
                              '${data[index].routeLng}',
                         */
                      },
                    ),
                  ),
                  Flexible(
                    child: Text(
                      data[index].Roue_Name.toString(),
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Comfortaa'
                      ),
                    ),
                  ),

                ],

              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.02,
            ),
          ],
        ),
      ),
    ),
  );
}
