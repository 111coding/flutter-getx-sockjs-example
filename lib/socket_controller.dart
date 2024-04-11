import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class SocketController extends GetxController {
  //
  StompClient? stompClient;
  List<String> messages = [];

  @override
  void dispose() {
    super.dispose();
    stompClient?.deactivate();
  }

  @override
  void onInit() {
    super.onInit();
    _connect();
  }

  void _connect() {
    stompClient = StompClient(
      /*
       * Node.js를 사용하면 Socket.io를 사용하는 것이 일반적이고 StompConfig()
       * -> ws://주소방식 ex) ws://192.168.0.5:8080
       * Spring을 사용한다면 SocketJS를 이용하는 것이 일반적입니다. StompConfig.SockJS()
       * -> http://주소/ws 방식 ex) http://192.168.0.5:8080/ws
       * 구현되어있는 서버쪽의 프로토콜을 확인 후 적절한 것 사용하시면 됩니다.
       */
      config: StompConfig.sockJS(
        url: 'server URL', // TODO
        webSocketConnectHeaders: {
          "transports": ["websocket"],
        },
        onConnect: (StompFrame frame) {
          print("onConnect");
          // 웹소켓 연결 되면 구독하기!
          stompClient?.subscribe(
            destination: '/user/queue/pub',
            headers: {},
            callback: (frame) {
              // 구독 콜백
              messages.add(frame.body!);
              update();
            },
          );
        },
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
        // 허용된 사용자만 접근 가능하다면 헤더에 Auth 정보 담기!
        //stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
        //webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
      ),
    );
    stompClient?.activate();
  }
}
