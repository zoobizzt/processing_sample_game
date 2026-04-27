//作成日：2025/7/22
//作成者：隅田　莉心（情25-0217）
//アプリケーション名：かき氷やさん！

//アプリケーション概要：
//かき氷を作るゲーム。
//ゲームを実行した際に、画面下に表示されるカップをカーソルで動かして
//かき氷器から降ってくる材料をゲットする。
//降ってくる材料は４種類で、材料の種類と重さによって、落ちる速度と獲得できるポイント数が異なる。
//30秒が経過したら、スコアに応じて完成したかき氷が表示されてゲーム終了。
//終了時、左側のリスタートボタンでもう一度ゲームを行える。
//右側のホームボタンでスタート画面に戻る。

//以下プログラム

import gifAnimation.*;  //gif読み込み

// かき氷の材料を管理するリスト
ArrayList<Material> materials;
Cup cup;  //プレイヤーのカップ

int score = 0;                  // スコア
int gameState = 0;              // 0:スタート, 1:プレイ中, 2:終了, 3:ルール画面
int startTime;
int gameDuration = 30 * 1000;   // ゲーム時間（30秒）

PFont font;

// ===== 画像：材料関連 =====
PImage imgIce, imgStrawberry, imgMilk, imgShiratama, imgCup;

// ===== 画像：背景 =====
PImage screenBg;    // スタート画面と終了画面で共通の背景
PImage gameBg;      // プレイ画面の背景

// ===== 画像：ボタン関連 =====
PImage startButtonImg;        //スタートボタン
PImage gameStartButtonImg;    //ゲームスタートボタン
PImage restartButtonImg, homeButtonImg;    //リスタート&ホームボタン

// ===== ボタン位置とサイズ =====
int buttonX, buttonY, buttonW, buttonH;      // スタート画面のスタートボタン
int gameStartButtonX, gameStartButtonY;      // ルール画面のゲームスタートボタン
int gameStartButtonW, gameStartButtonH;      
int restartX, restartY, homeX, homeY;        // 終了画面のボタン

// ===== 画像：結果（かき氷の完成度） =====
PImage resultDelicious, resultNormal, resultSmall, resultFail;

// === GIF ===
Gif titleGif, kanseiGif;


void setup() {
  size(600, 700);
  //font = loadFont("marukiya-48.vlw");
  font = createFont("DonguriDuel.ttf",32);
  textFont(font);

  cup = new Cup();
  materials = new ArrayList<Material>();

  // 材料画像の読み込み
  imgIce = loadImage("ice_100.png");
  imgStrawberry = loadImage("strawberry_100.png");
  imgMilk = loadImage("milk_100.png");
  imgShiratama = loadImage("shiratama_100.png");
  imgCup = loadImage("cup_250.png");

  // 背景
  screenBg = loadImage("kakigoriyasan_bg.png");
  screenBg.resize(width, height);
  gameBg = loadImage("game_background.png");
  gameBg.resize(width, height);

  //　ボタン
  startButtonImg = loadImage("startButton_250.png");          //スタートボタン
  gameStartButtonImg = loadImage("gameStartButton_250.png");  //ゲームスタートボタン
  gameStartButtonW = gameStartButtonImg.width;
  gameStartButtonH = gameStartButtonImg.height;
  gameStartButtonX = width / 2 - gameStartButtonW / 2;
  gameStartButtonY = height - 150 - gameStartButtonH / 2;   // 画面下寄り

  restartButtonImg = loadImage("restart_button_100.png");    //リスタートボタン
  homeButtonImg = loadImage("home_button_100.png");          //ホームボタン
  buttonW = restartButtonImg.width;
  buttonH = restartButtonImg.height;

  // ホームとリスタートボタン、横並び用の位置（画面中央に２つ並ぶように調整）
  restartX = width/2 - buttonW - 20; // 左側
  homeX = width/2 + 20;              // 右側
  restartY = homeY = height - 150;   // 同じ高さ

  //かき氷の結果表示
  resultDelicious = loadImage("result_delicious_250.png");
  resultNormal = loadImage("result_normal_250.png");
  resultSmall = loadImage("result_small_250.png");
  resultFail = loadImage("result_fail_250.png");

  //GIF読み込み
  titleGif = new Gif(this, "kakigoriyasan_384.gif");  // 「タイトル」gif
  titleGif.play();
  kanseiGif = new Gif(this, "kansei_384.gif");  //「完成！」gif
  kanseiGif.loop();  // 繰り返し再生
}


void draw() {
  background(200, 230, 255);
  if (gameState == 0) {
    showStartScreen();            //スタート画面
  } else if (gameState == 1) {
    playGame();                   //プレイ画面
  } else if (gameState == 2) {
    showEndScreen();              //終了画面
  } else if (gameState == 3) {
    showInstructionScreen();      //ルール画面
  }
}

// ===== スタート画面 =====

void showStartScreen() {
  image(screenBg, 0, 0);  // かき氷屋の背景を表示
  // 背景と半透明黒
  noStroke();
  fill(0, 80);  // 0は黒、80は透明度
  rect(0, 0, width, height);  // 画面全体に黒をかける
  image(titleGif, width/2 - titleGif.width/2, height/2 - 300);  //タイトルを中央に表示

  //スタートボタンの位置と描画
  buttonW = startButtonImg.width;
  buttonH = startButtonImg.height;
  buttonX = width/2 - buttonW/2;
  buttonY = height/2 - buttonH/2;
  image(startButtonImg, buttonX, buttonY, buttonW, buttonH);
}

// ===== ルール画面 =====

void showInstructionScreen() {
  // 背景と半透明黒
  image(screenBg, 0, 0);
  fill(0, 80); //透明度
  rect(0, 0, width, height);  // 画面全体に黒をかける

  // テキスト
  textAlign(CENTER);
  float x = width / 2;
  float yTitle = 100;
  float yInstruction = 190;  //説明文の開始位置
  float lineSpacing = 50;    // 行間

  //「- rule -」を縁取り付きで描く
  textSize(30);
  String title = "- rule -";

  // 水色の縁（周囲に4〜8回描画）
  fill(0, 160, 255);
  for (int dx = -2; dx <= 2; dx++) {
    for (int dy = -2; dy <= 2; dy++) {
      if (dx != 0 || dy != 0) {
        text(title, x + dx, yTitle + dy);
      }
    }
  }
  fill(255); // 文字の中（白）
  text(title, x, yTitle);

  // ruleの本文
  textSize(20);
  String[] instruction = {
    "oishi kakigori wo tsukurou !\n",
    "cup wo mouse de ugokashite\n", 
    "ochitekuru zairyo wo cup ni iretene !\n", 
    "zairyo wo takusan GET suruhodo\n", 
    "dekiagaru kakigori mo okikunaruyo !\n", 
    "donna kakigori ga dekirukana ?\n", 
    "otanosimini !"
  };

  for (int i = 0; i < instruction.length; i++) {
    // 各行の文字を、間隔をあけて下にずらして表示
    float y = yInstruction + i * lineSpacing;

    // 水色の縁（周囲に4〜8回描画）
    fill(0, 160, 255); // 水色
    for (int dx = -2; dx <= 2; dx++) {
      for (int dy = -2; dy <= 2; dy++) {
        if (dx != 0 || dy != 0) {
          text(instruction[i], x + dx, y + dy);
        }
      }
    }

    fill(255); // 文字の中（白）
    text(instruction[i], x, y);
  }

  // 「GAMESTART」ボタン
  image(gameStartButtonImg, gameStartButtonX, gameStartButtonY);
}


// ===== プレイ画面 =====

void playGame() {
  int elapsed = millis() - startTime;
  imageMode(CORNER);
  image(gameBg, 0, 0);  //背景画像を表示

  if (elapsed >= gameDuration) {
    gameState = 2;
    return;
  }

  float speedMultiplier = 1 + (elapsed / 10000.0); // 経過時間に応じて難易度上がる
  if (frameCount % 30 == 0) {
    materials.add(new Material(speedMultiplier));
  }

  // 材料の移動・表示・当たり判定
  for (int i = materials.size() - 1; i >= 0; i--) {
    Material m = materials.get(i);
    m.update();
    m.display();

    if (m.hits(cup)) {
      score += m.score;   //素材ごとに点数追加
      materials.remove(i);
    } else if (m.y > height) {
      materials.remove(i);
    }
  }

  cup.update();
  cup.display();

  // 獲得数と残り時間を表示
  fill(255);
  textSize(25);
  text("GET: " + score, 500, 40);
  text("TIMER: " + (gameDuration - elapsed)/1000 + " s", 100, 40);
}

// ===== 終了画面 =====

void showEndScreen() {
  image(screenBg, 0, 0);      // かき氷屋の背景を表示
  // 背景と半透明黒
  fill(0, 80);  // 透明度
  rect(0, 0, width, height);  // 画面全体に黒をかける
  imageMode(CENTER);

  image(kanseiGif, width/2, height/2 - 250);  //「完成！」の位置設定
  fill(255);
  textSize(25);
  text("GET: " + score, 500, 40);   //スコア表示

  //かき氷の材料スコア数別表示
  PImage kakigoriImg;
  if (score >= 65) {
    image(resultDelicious, width/2, height/2 - 130);
    kakigoriImg = loadImage("kakigori_large_260.png");
  } else if (score >= 30) {
    image(resultNormal, width/2, height/2 - 130);
    kakigoriImg = loadImage("kakigori_medium_260.png");
  } else if (score >= 20) {
    image(resultSmall, width/2, height/2 - 130);
    kakigoriImg = loadImage("kakigori_small_260.png");
  } else {
    image(resultFail, width/2, height/2 - 130);
    kakigoriImg = loadImage("cup_250.png");
  }

  // かき氷画像の表示
  image(kakigoriImg, width/2, height/2 + 50);  //真ん中より-50下

  //リスタートボタンとホームボタン
  imageMode(CORNER);
  image(restartButtonImg, restartX, restartY);
  image(homeButtonImg, homeX, homeY);
}

// ===== クリックでゲーム開始・リスタート・ホームに戻る処理 =====

void mousePressed() {
  if (gameState == 0) {
    // 「START」ボタンでルール画面へ
    if (mouseY > height/2 - 30 && mouseY < height/2 + 30) {
      gameState = 3;
    }
  } else if (gameState == 3) {
    //ルール画面の「GAMESTART」ボタンでゲームスタート
    if (mouseX > gameStartButtonX && mouseX < gameStartButtonX + gameStartButtonW &&
      mouseY > gameStartButtonY && mouseY < gameStartButtonY + gameStartButtonH) {
      gameState = 1;
      startTime = millis();
      score = 0;
      materials.clear();
    }
  } else if (gameState == 2) {
    // リスタートボタン
    if (mouseX > restartX && mouseX < restartX + buttonW &&
      mouseY > restartY && mouseY < restartY + buttonH) {
      resetGame(); // リスタート処理
    }

    // ホームボタン
    if (mouseX > homeX && mouseX < homeX + buttonW &&
      mouseY > homeY && mouseY < homeY + buttonH) {
      gameState = 0; // ホームに戻る
    }
  }
}

void resetGame() {
  score = 0;
  materials.clear();
  startTime = millis();
  gameState = 1;  // プレイ画面へ戻る
}

// ===== 材料クラス（落下する素材） =====

class Material {
  float x, y;   //素材の位置
  float speed;  //落下スピード
  String type;  //素材の種類
  int score;    //点数

  Material(float multiplier) {
    String[] types = {"ice", "strawberry", "milk", "shiratama"};
    type = types[int(random(types.length))];    //4種類からランダムに選ぶ
    x = random(width/2 - 200, width/2 + 200);   //かき氷器からランダムに材料が落ちてくる
    y = 170;  //材料が画面内170ピクセル下から落ち始める

    if (type.equals("ice")) {
      speed = random(2, 3);    //氷は一番軽いから落ちるスピード遅め（ランダム：２〜３）
      score = 1;
    } else if (type.equals("strawberry")) {
      speed = random(3, 4);    //イチゴは少し重めだから落ちるスピード少し速め（ランダム：３〜４）
      score = 2;
    } else if (type.equals("milk")) {
      speed = random(5, 6);    //練乳は液体だから落ちるスピード速め（ランダム：５〜６）
      score = 3;
    } else if (type.equals("shiratama")) {
      speed = random(6, 7);    //白玉は一番重くて落ちるスピード最速（ランダム：６〜７）
      score = 4;
    }

    // 素材の種類ごとの基本スピードに倍率をかけて、全体の落下速度を調整
    speed *= multiplier;
  }

  void update() {
    y += speed;  //1フレームごと下に落ちる
  }

  // 素材ごとの画像を表示
  void display() {
    imageMode(CENTER);
    if (type.equals("ice")) {
      image(imgIce, x, y);
    } else if (type.equals("strawberry")) {
      image(imgStrawberry, x, y);
    } else if (type.equals("milk")) {
      image(imgMilk, x, y);
    } else if (type.equals("shiratama")) {
      image(imgShiratama, x, y);
    }
  }

  //カップの衝突判定（30未満ならキャッチ成功）
  boolean hits(Cup c) {
    return dist(x, y, c.x, c.y) < 30;
  }
}

// ===== カップクラス（プレイヤーの操作カップ） =====

class Cup {
  float x, y;
  Cup() {
    x = width/2;        //初期位置：中央
    y = height - 130;   //カップのyの位置
  }

  void update() {
    x = mouseX; // マウスで横移動（横移動のみ）
  }

  void display() {
    imageMode(CENTER);
    image(imgCup, x, y);  // カップ画像の描画位置
  }
}
