import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_gpt/color_pallete.dart';
import 'package:my_gpt/utilities/openai_service.dart';
import 'package:my_gpt/widgets/feature_box.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();

  String lastWords = '';
  String? generatedImageUrl;
  String? generatedContent;
  int start=200;
  int delay=200;

  final OpenAISerive openAISerive = OpenAISerive();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: Text("Sunny")),
        leading: Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant pictujre
            Builder(
              builder: (context) {
                return ZoomIn(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: 120,
                          width: 120,
                          margin: EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                              color: Pallete.assistantCircleColor,
                              shape: BoxShape.circle),
                        ),
                      ),
                      Container(
                        height: 123,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/virtualAssistant.png'))),
                      )
                    ],
                  ),
                );
              }
            ),

            //chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 30).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Pallete.borderColor),
                      borderRadius: BorderRadius.circular(20)
                          .copyWith(topLeft: Radius.zero)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      generatedContent == null
                          ? "Hello, What task can I do for you?"
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!)),
              ),
            // feature list text
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Here are a few features",
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),

            // feature list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  // flutter.minSdkVersion
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: FeatureBox(
                        color: Pallete.firstSuggestionBoxColor,
                        headerText: "ChatGPT",
                        descriptionText:
                            "A smater way to stay organized and informed with ChatGPT"),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start+delay),
                    child: FeatureBox(
                        color: Pallete.secondSuggestionBoxColor,
                        headerText: "Dall-E",
                        descriptionText:
                            "Get inspired and stay creative with your personal assistant powered by Dall-E"),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start+delay*2),
                    child: FeatureBox(
                        color: Pallete.thirdSuggestionBoxColor,
                        headerText: "Smart Voice Assistant",
                        descriptionText:
                            "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start+3*delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAISerive.isArtPromptAPI(lastWords);
              print("Speaking:"+lastWords);
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening?Icons.stop:Icons.mic),
        ),
      ),
    );
  }
}
