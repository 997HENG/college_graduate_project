part of 'webrtc_repository.dart';

const Map<String, dynamic> defaultIceConfiguration = {
  'iceServers': [
    {
      'urls': [
        'stun:stun1.l.google.com:19302',
        'stun:stun2.l.google.com:19302',
      ]
    }
  ]
};

//  'iceServers': [
//     {
//       'urls': [
//         'stun:stun3.l.google.com:19302',
//         'stun:stun4.l.google.com:19302',
//       ]
//     }
//   ]

// 'iceServers': [
//     {'url': 'turn:192.168.88.99:3478', 'username': 'foo', 'credential': 'bar'},
//   ]

const Map<String, dynamic> defaultCameraConstraints = {
  "audio": true,
  "video": {
    "facingMode": "user",
    "mandatory": {
      'width': '1920',
      'height': '1080',
      'minFrameRate': '30',
      'idealFrameRate': '60',
    }
  }
};

const Map<String, dynamic> defaultDisplayConstraints = {
  "video": true,
};
