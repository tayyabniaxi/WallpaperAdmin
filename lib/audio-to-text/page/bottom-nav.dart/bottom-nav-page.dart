import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/bottom-nav-bloc/bottom-nav-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/bottom-nav-bloc/bottom-nav-event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/bottom-nav-bloc/bottom-nav-state.dart';
import 'package:new_wall_paper_app/audio-to-text/page/home-page.dart';
import 'package:new_wall_paper_app/audio-to-text/page/show-history.dart';
import 'package:new_wall_paper_app/utils/app-color.dart';
import 'package:new_wall_paper_app/utils/app-icon.dart';

class BottomNavigationPage extends StatelessWidget {
  final List<Widget> pages = [
     HomeScreen(),
   OpenedPdfsPage(),
    const Center(child: Text('Add Page')),
    Center(child: Text('history Page')),
    Center(child: Text('Profile Page')),
  ];

  final List<IconData> iconList = [
    Icons.home,
    Icons.search,
    Icons.notifications,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavigationBloc(),
      child: BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
        builder: (context, state) {
          return Scaffold(
            body: pages[state.selectedIndex],
            bottomNavigationBar: ConvexAppBar(
              elevation: 0,
              style: TabStyle.fixedCircle,
              backgroundColor: Colors.white,
              activeColor: AppColor.primaryColor,
              color: Colors.grey,
              items: [
                TabItem(
                    icon: SvgPicture.asset(
                      AppImage.home,
                      color: state.selectedIndex == 0
                          ? AppColor.primaryColor
                          : Colors.grey,
                    ),
                    title: 'Home'),
                TabItem(
                    icon: SvgPicture.asset(
                      AppImage.search,
                      color: state.selectedIndex == 1
                          ? AppColor.primaryColor
                          : Colors.grey,
                    ),
                    title: 'Search'),
                TabItem(
                    icon: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SvgPicture.asset(
                        AppImage.plus,
                        color: state.selectedIndex == 2
                            ? Colors.white
                            : Colors.black54,
                        width: MediaQuery.of(context).size.width * 0.04,
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                    ),
                    title: '',
                    isIconBlend: false),
                TabItem(
                    icon: SvgPicture.asset(
                      AppImage.history,
                      color: state.selectedIndex == 3
                          ? AppColor.primaryColor
                          : Colors.grey,
                    ),
                    title: 'History'),
                TabItem(
                    icon: SvgPicture.asset(
                      AppImage.profile,
                      color: state.selectedIndex == 4
                          ? AppColor.primaryColor
                          : Colors.grey,
                    ),
                    title: 'Profile'),
              ],
              initialActiveIndex: state.selectedIndex,
              onTap: (index) {
                context.read<BottomNavigationBloc>().add(NavigateToPage(index));
              },
            ),
          );
        },
      ),
    );
  }
}
