part of 'llm_model_info.dart';

enum Hardware {
  cpu,
  gpu,
}

enum ModelType {
  gemma4bcpu,
  gemma4bgpu,
  gemma7bgpu;

  Hardware get hardware => switch (this) {
        gemma4bcpu => Hardware.cpu,
        gemma4bgpu => Hardware.gpu,
        gemma7bgpu => Hardware.gpu,
      };

  String get name => switch (this) {
        gemma4bcpu => 'gemma 4b cpu',
        gemma4bgpu => 'gemma 4b gpu',
        gemma7bgpu => 'gemma 7b gpu',
      };
}

enum ModelState {
  downloaded,
  downloading,
  empty;
}

const gemma4bCpuFileName = 'GEMMA_4B_CPU.bin';
const gemma4bGpuFileName = 'GEMMA_4B_GPU.bin';
const gemma7bGpuFileName = 'GEMMA_7B_GPU.bin';

const gemma4bCpuDownloadlocation =
    'https://storage.googleapis.com/kagglesdsdata/models/21998/26133/gemma-1.1-2b-it-cpu-int4.bin?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=gcp-kaggle-com%40kaggle-161607.iam.gserviceaccount.com%2F20241204%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20241204T013327Z&X-Goog-Expires=259200&X-Goog-SignedHeaders=host&X-Goog-Signature=3c3e68f62ec1213f5abc818f2d06bdb3e52dff73d882fdc1bc857bbe8d4dc1604524f5127024d0f7cb39b1d3e32fe53cc7c56570b8adc8a038dfe8cafec0c59c0cb00f9822dc42c60aa57e1cf803c4c1f52a4abf64f89aecda21a54dbdfc22f9f156ea9c6795a3a9c0b362f6f5301e90a02525a1e185fece6d6cac524c959366e58c0609c530531b614a654443c4b6b9abbdb1574e88692736f13086428e07968dfb0a846a57d109f207eba6102b961550250be3778c55331106305b2abea1c5f3f84f209e72f565c34b2c0f3cf54404627f25c9c9ca2d926524f991df9b4d94d8958876e4864c4986e9b2d9dcacc38affdee0217704f98fbf175c722fb5eb52';

const gemma4bGpuDownloadlocation =
    'https://storage.googleapis.com/kagglesdsdata/models/21999/26135/gemma-1.1-2b-it-gpu-int4.bin?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=gcp-kaggle-com%40kaggle-161607.iam.gserviceaccount.com%2F20241204%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20241204T013337Z&X-Goog-Expires=259200&X-Goog-SignedHeaders=host&X-Goog-Signature=56bd4e5b51451d464415eba55730c53baabe4d67a47badcaec62e95f8dd573712dab6bc1d213ba8a0bbe58c1222219bd8c5a6df1d308e66cc5508670b65593ec3db19adac791a651a6f86cbb49227abd77e2908e1e393d8925672efa9bc4401e083dd40a962aae67f2d279eae7e57e403c451c30ccb1601786b9fac28cca4f228317b687fb1ae2e2c70ebfb5e822f3b31c6e953911c1699011e93e90044ff50bef47efcb387cd8b7ef2414a6e9666d37173433c384645d378211a233a453659502ee463f342143ced897f7b021e312365c4b52e4abd570112c0a013ce56dfaf0991b593fa8e5654ee2a1c44eef0982aa45c8b224bb845f37cb34ef4e1c14afe1';

const gemma7bGpuDownloadlocation =
    'https://storage.googleapis.com/kagglesdsdata/models/38119/45460/gemma-1.1-7b-it-gpu-int8.bin?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=gcp-kaggle-com%40kaggle-161607.iam.gserviceaccount.com%2F20241204%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20241204T013352Z&X-Goog-Expires=259200&X-Goog-SignedHeaders=host&X-Goog-Signature=5cbfe5f31febff62cd37b5f6fa1222aea38b111f5b41c5482319298136563ad869142fe97cb532e028c9152124b4d3d995fbdb4c1391f80e2d4773c022fa629780ee5c133984a2a9be82782edff7f4aaa9c8a4992e772df663802b42ea9462f7f7d0e673b602df4716f22e2f71499ddc12b897e3591f3a8dbace667b17c4db608f0e17198dabd51a144773646b001d95a3cb39a3abc0a2d54433fbf73648f622470c55730e5a8723bbe78d7d1e2350d94a5794e45ca220063c374466ff6dbc03ed7e0ffdc9a509e3006725e6b35d9ed14d61c147b4c5ae629dabbd7e38c371cc94e02cc3da98c0ed00cf25a5080529119f802b85f33674e586c2780a25e97576';

const gemma4bCpuFileSize = 1346427328;
const gemma4bGpuFileSize = 1346502656;
const gemma7bGpuFileSize = 8551137280;
