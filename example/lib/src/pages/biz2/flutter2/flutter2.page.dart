// Copyright (c) 2022 foxsofter.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import '../../route.dart';
import '../../types/people.dart';

part 'flutter2.state.dart';
part 'flutter2.context.dart';

class Flutter2Page extends NavigatorStatefulPage {
  const Flutter2Page({
    super.key,
    required super.moduleContext,
    super.params,
    super.url,
    super.index,
  });

  @override
  _Flutter2PageState createState() => _Flutter2PageState();
}

class _Flutter2PageState extends State<Flutter2Page> {
  final _channel = ThrioChannel(channel: 'custom_thrio_channel');
  @override
  void initState() {
    super.initState();
    _channel.registryMethodCall('sayHello', ([final arguments]) async {
      ThrioLogger.v('sayHello from native');
    });
  }

  @override
  void dispose() {
    ThrioLogger.d('page2 dispose');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => NavigatorPageNotify(
      name: 'page2Notify',
      onPageNotify: (final params) => ThrioLogger.v('flutter2 receive notify:$params'),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('thrio_example', style: TextStyle(color: Colors.black)),
            leading: context.showPopAwareWidget(const IconButton(
              color: Colors.black,
              tooltip: 'back',
              icon: Icon(Icons.arrow_back_ios),
              onPressed: ThrioNavigator.pop,
            )),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    'flutter2: index is ${widget.index}',
                    style: const TextStyle(fontSize: 28, color: Colors.blue),
                  ),
                ),
                InkWell(
                  onTap: () => ThrioNavigator.push(
                    url: '/biz1/flutter3',
                    params: {
                      '1': {'2': '3'}
                    },
                  ),
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.yellow,
                      child: const Text(
                        'push flutter3',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: () => ThrioNavigator.remove(url: '/biz2/flutter2'),
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.yellow,
                      child: const Text(
                        'remove flutter2',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: () => ThrioNavigator.pop(params: People(name: '大宝剑', age: 0, sex: 'x')),
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.yellow,
                      child: const Text(
                        'pop',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: () async {
                    final params = await ThrioNavigator.push(url: '/biz2/native2', params: {
                      '1': {'2': '3'}
                    });
                    ThrioLogger.v('/biz1/native1 popped:$params');
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.grey,
                      child: const Text(
                        'push native2',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: () => ThrioNavigator.remove(url: '/biz1/native1'),
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.grey,
                      child: const Text(
                        'pop native1',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: () {
                    ThrioNavigator.notify(
                        url: '/biz1/flutter1',
                        name: 'page1Notify',
                        params: People(name: '大宝剑', age: 1, sex: 'x'));
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.grey,
                      child: const Text(
                        'notify flutter1',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: () {
                    ThrioNavigator.notify(
                        url: '/biz2/flutter2',
                        name: 'page2Notify',
                        params: People(name: '大宝剑', age: 2, sex: 'x'));
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.grey,
                      child: const Text(
                        'notify flutter2',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: () {
                    ThrioNavigator.notify(
                        name: 'all_page_notify_from_flutter2',
                        params: People(name: '大宝剑', age: 2, sex: 'x'));
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.grey,
                      child: const Text(
                        'notify all',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: () {
                    ThrioNavigator.pushReplace(url: root.biz1.flutter1.home.url);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.grey,
                      child: const Text(
                        'pushReplace flutter1',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: root.biz1.flutter5.push,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.grey,
                      child: const Text(
                        'push flutter5',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
                InkWell(
                  onTap: root.biz2.flutter6.push,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      color: Colors.grey,
                      child: const Text(
                        'push flutter6',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      )),
                ),
              ]),
            ),
          )));
}
