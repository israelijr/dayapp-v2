import re
with open('lib/screens/group_stories_screen.dart', 'r') as f:
    content = f.read()

content = content.replace('''child: PulseAnimation(scaleTarget: 1.06, child: FloatingActionButton.extended(
            onPressed: () {''', '''child: PulseAnimation(
            scaleTarget: 1.06,
            child: FloatingActionButton.extended(
              onPressed: () {''')

content = content.replace('''            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.newStory),
          ),
        ),''', '''            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.newStory),
            ),
          ),
        ),''')

with open('lib/screens/group_stories_screen.dart', 'w') as f:
    f.write("import 'package:dayapp/widgets/pulse_animation.dart';\n" + content)
