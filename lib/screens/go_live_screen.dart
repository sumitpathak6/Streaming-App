import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:twitch_clone/util/colors.dart';
import 'package:twitch_clone/widgets/custom_button.dart';
import 'package:twitch_clone/widgets/custom_textfield.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({super.key});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //const SizedBox(height: 30),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: buttonColor,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: buttonColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_open,
                            color: buttonColor,
                            size: 40,
                          ),
                          const SizedBox(height: 50),
                          Text(
                            'Select your thumbnail',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey.shade400),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(controller: _titleController),
                    )
                  ],
                )
              ],
            ),
            Padding(padding: const EdgeInsets.only(bottom: 10), child: CustomButton(onTap: (){}, text: 'Go Live!'),)
          ],
        ),
      ),
    );
  }
}
