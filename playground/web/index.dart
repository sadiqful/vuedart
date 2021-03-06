import 'package:vue/vue.dart';
import 'package:vue/plugins/vue_router.dart';
import 'package:vue_playground/todo_item.dart';

import 'dart:async';
import 'dart:html';


@VueComponent(template: '<p>todo item #{{id}} <router-view></router-view></p>')
class SingleItem extends VueComponentBase with VueRouterMixin {
  @computed
  int get id => int.parse($route.params['id']);
}


@VueComponent(template: '<p>todo item #{{id}} INFO</p>')
class SingleItemInfo extends VueComponentBase with VueRouterMixin {
  @computed
  int get id => int.parse($route.params['id']);
}


@VueComponent(template: '''
  <div>
    <input v-model="checkedModel" type="checkbox"/>
    <button @click="reset">Reset</button>
  </div>
''')
class CheckBox extends VueComponentBase {
  static const _EVENT = 'check-status-changed';
  static final checkStatusChanged = VueEventSpec<bool>(CheckBox._EVENT);
  VueEventSink<bool> checkStatusChangedSink;
  VueEventStream<bool> checkStatusChangedStream;

  @override
  void lifecycleCreated() {
    checkStatusChangedSink = checkStatusChanged.createSink(this);
    checkStatusChangedStream = checkStatusChanged.createStream(this);

    checkStatusChangedStream.listen((bool checked) => print('checked is now $checked'));
  }


  @model(event: CheckBox._EVENT)
  // @model()
  @prop
  bool checked = false;

  @computed
  bool get checkedModel => checked;
  @computed
  set checkedModel(bool value) => checkStatusChangedSink.add(value);

  @method
  void reset() => checkedModel = false;
}


@VueApp(el: '#app', components: const [TodoItem, CheckBox])
class App extends VueAppBase with VueRouterMixin, TodoMixin {
  @override
  void lifecycleMounted() {
    print('mounted!');
    $nextTick().then((_) {
      print('nextTick called');
    });
  }

  @data
  bool checked = false;

  @data
  List groceryList = [
    TodoEntry(id: 0, text: 'Vegetables'),
    TodoEntry(id: 1, text: 'Cheese'),
    TodoEntry(id: 2, text: 'Whatever else humans are supposed to eat'),
  ];

  @method
  void click(MouseEvent evt) {
    $router.replace(VueRouterLocation(path: '/item/10')).onComplete.then((VueRouteInfo info) {
      print('replace onComplete: ${info.params}');
    });
  }
}


App app;


Future main() async {
  final router = VueRouter(routes: [
    VueRoute(path: '/item/:id', component: SingleItem(), children: [
      VueRoute(path: 'info', component: SingleItemInfo()),
    ]),
    VueRoute(path: '/singleitem/:id', components: {
      'single': SingleItem(),
    }),
  ]);

  app = App();
  app.create(options: [router]);
}
