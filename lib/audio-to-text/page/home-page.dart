// ignore_for_file: sized_box_for_whitespace, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/home-page-bloc/home-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/home-page-bloc/home-event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/home-page-bloc/home-state.dart';
import 'package:new_wall_paper_app/audio-to-text/page/docs-reader-screen.dart';
import 'package:new_wall_paper_app/audio-to-text/page/file-picker.dart';
import 'package:new_wall_paper_app/audio-to-text/page/google_drive_reader_screen.dart';
import 'package:new_wall_paper_app/audio-to-text/page/imgReader-screen.dart';
import 'package:new_wall_paper_app/audio-to-text/page/link_reader_screen.dart';
import 'package:new_wall_paper_app/audio-to-text/page/read_email/mail_folder.dart';
import 'package:new_wall_paper_app/audio-to-text/page/write-past-text.dart';
import 'package:new_wall_paper_app/utils/app-color.dart';
import 'package:new_wall_paper_app/utils/app-icon.dart';
import 'package:new_wall_paper_app/widget/common-text.dart';
import 'package:new_wall_paper_app/widget/height-widget.dart';
import 'package:new_wall_paper_app/widget/home_book_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<HomePageBloc>().add(LoadItemsEvent());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      
      body: BlocBuilder<HomePageBloc, HomePageSate>(builder: (context, state) {
        if (state is ItemLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ItemLoaded) {
          return ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: AppColor.homeBgColor.withOpacity(0.7),
                    filled: true,
                    hintText: "Search Source",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        height: MediaQuery.of(context).size.height * 0.01,
                        width: 10,
                      ),
                    ),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              height(size: 0.024),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    past_text(context),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    import_method(context),
                  ],
                ),
              ),
              height(size: 0.006),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 13),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    height(size: 0.01),
                    CommonText(
                      color: Colors.black,
                      size: 0.021,
                      fontWeight: FontWeight.w600,
                      title: "Import & Listen",
                    ),
                    height(size: 0.02),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return InkWell(
                            onTap: () {
                              if (item.text == 'Pic') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImageReaderScreen(
                                            isCamera: false,
                                          )),
                                );
                              } else if (item.text == 'More') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DocxReaderHome()),
                                );
                              } else if (item.text == 'Files') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          // const PDFToTextScreen()),
                                          FileProcessorScreen()),
                                );
                              } else if (item.text == 'Text') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WriteAndTextPage(
                                            isText: true,
                                          )),
                                );
                              } else if (item.text == "Scan") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImageReaderScreen(
                                            isCamera: true,
                                          )),
                                );
                              } else if (item.text == "Link") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LinkReaderScreen()),
                                );
                              } else if (item.text == "Gdrive") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DriveFolderScreen()),
                                );
                              } else if (item.text == "Email") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EmailFolderScreen()),
                                );
                              }
                            },
                            child: Container(
                              // height: MediaQuery.of(context).size.height * 0.1,
                              // width: MediaQuery.of(context).size.width * 0.1,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: item.gradientColors,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(item.imageUrl),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.2),
                                      BlendMode.darken),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      item.imageUrl,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.037,
                                    ),
                                    height(size: 0.01),
                                    Center(
                                      child: CommonText(
                                        color: Colors.white,
                                        size: 0.016,
                                        fontWeight: FontWeight.w500,
                                        title: item.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ));
                      },
                    ),
                  ],
                ),
              ),
              height(size: 0.006),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          color: Colors.black,
                          size: 0.021,
                          fontWeight: FontWeight.w600,
                          title: "Explore Books",
                        ),  CommonText(
                          color: Colors.blue,
                          size: 0.02,
                          fontWeight: FontWeight.w600,
                          title: "View All Categories",
                        ),
                      ],
                    ),
                    height(size: 0.03),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BookCard(
                            backgroundColor: [
                              ContainerGradientColor.pinklight,
                              ContainerGradientColor.pinkdark
                            ],
                            image: "assets/images/one.png",
                            title: "Business Adventures",
                            subtitle: "John Brooks",
                          ),
                          BookCard(
                            backgroundColor: [
                              ContainerGradientColor.bluelight,
                              ContainerGradientColor.bluedark
                            ],
                            image: "assets/images/two.png",
                            title: "Don't Look Back",
                            subtitle: "Isaac Nelson",
                          ),
                          BookCard(
                            // backgroundColor: Colors.orange,
                            backgroundColor: [
                              ContainerGradientColor.orangelight,
                              ContainerGradientColor.orangedark
                            ],
                            image: "assets/images/three.png",
                            title: "A Million to One",
                            subtitle: "Tony Faggioli",
                          ),
                        ],
                      ),
                    ),
                      height(size: 0.03),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          color: Colors.black,
                          size: 0.021,
                          fontWeight: FontWeight.w600,
                          title: "Micro Learning",
                        ),  CommonText(
                          color: Colors.blue,
                          size: 0.02,
                          fontWeight: FontWeight.w600,
                          title: "View All Categories",
                        ),
                      ],
                    ),
                    height(size: 0.03),
                     const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BookCard(
                            backgroundColor: [
                              ContainerGradientColor.pinklight,
                              ContainerGradientColor.pinkdark
                            ],
                            image: "assets/images/one.png",
                            title: "Business Adventures",
                            subtitle: "John Brooks",
                          ),
                          BookCard(
                            backgroundColor: [
                              ContainerGradientColor.bluelight,
                              ContainerGradientColor.bluedark
                            ],
                            image: "assets/images/two.png",
                            title: "Don't Look Back",
                            subtitle: "Isaac Nelson",
                          ),
                          BookCard(
                            // backgroundColor: Colors.orange,
                            backgroundColor: [
                              ContainerGradientColor.orangelight,
                              ContainerGradientColor.orangedark
                            ],
                            image: "assets/images/three.png",
                            title: "A Million to One",
                            subtitle: "Tony Faggioli",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state is ItemError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('No data available'));
      }),
    );
  }

  Container past_text(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.23,
      width: MediaQuery.of(context).size.width * 0.45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
            transform: GradientRotation(0.7),
            colors: [
              ContainerGradientColor.purplelight,
              ContainerGradientColor.purpledark
            ]),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.23,
        width: MediaQuery.of(context).size.width * 0.4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.06,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Positioned(
                      top: MediaQuery.of(context).size.height * 0.05,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.01,
                        width: MediaQuery.of(context).size.width * 0.07,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 10,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.053,
                width: MediaQuery.of(context).size.width * 0.28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    AppImage.past_text,
                    height: MediaQuery.of(context).size.height * 0.04,
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.055,
              right: -6,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.16),
                        child: Positioned(
                          right: 0,
                          top: MediaQuery.of(context).size.height * 0.05,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.01,
                            width: MediaQuery.of(context).size.width * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget import_method(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.23,
      width: MediaQuery.of(context).size.width * 0.45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
            transform: GradientRotation(0.7),
            colors: [
              ContainerGradientColor.importdark,
              ContainerGradientColor.importlight
            ]),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.24,
        width: MediaQuery.of(context).size.width * 0.4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.06,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Positioned(
                      top: MediaQuery.of(context).size.height * 0.05,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.01,
                        width: MediaQuery.of(context).size.width * 0.07,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 10,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.053,
                width: MediaQuery.of(context).size.width * 0.28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    AppImage.importWeb,
                    height: MediaQuery.of(context).size.height * 0.04,
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.055,
              right: -6,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.16),
                        child: Positioned(
                          right: 0,
                          top: MediaQuery.of(context).size.height * 0.05,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.01,
                            width: MediaQuery.of(context).size.width * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


