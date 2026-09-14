import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../data/first_launch_design_draft.dart';
import 'design_avatar.dart';
import 'first_launch_hero_panel.dart';

const firstColleagueNameDesignScreen = 'Alex';

enum FaceLabPreviewModeDesignScreen {
  firstLaunch,
  modifySelf,
  modifyPerson,
  createPerson,
}

class FaceLabDesignScreen extends StatefulWidget {
  const FaceLabDesignScreen({
    super.key,
    this.firstLaunch = false,
    this.creatingColleague = false,
    this.colleagueName = firstColleagueNameDesignScreen,
  });

  final bool firstLaunch;
  final bool creatingColleague;
  final String colleagueName;

  @override
  State<FaceLabDesignScreen> createState() => _FaceLabDesignScreenState();
}

class _FaceLabDesignScreenState extends State<FaceLabDesignScreen> {
  final configurationsDesignScreen = [
    _AvatarConfiguration(),
    _AvatarConfiguration(
      face: 1,
      skin: 2,
      hair: 2,
      hairColor: 1,
      eyes: 1,
      mouth: 1,
      accessory: 1,
      outfitColor: 2,
    ),
  ];

  int targetDesignScreen = 0;
  bool selfSavedDesignScreen = false;
  bool colleagueSavedDesignScreen = false;
  String? statusDesignScreen;
  String get colleagueName => widget.colleagueName;
  late FaceLabPreviewModeDesignScreen previewModeDesignScreen;

  bool get firstLaunchModeDesignScreen =>
      previewModeDesignScreen == FaceLabPreviewModeDesignScreen.firstLaunch;
  bool get modifyingSelfDesignScreen =>
      previewModeDesignScreen == FaceLabPreviewModeDesignScreen.modifySelf;
  bool get creatingPersonDesignScreen =>
      previewModeDesignScreen == FaceLabPreviewModeDesignScreen.createPerson;

  _AvatarConfiguration get configuration =>
      configurationsDesignScreen[targetDesignScreen];

  @override
  void initState() {
    super.initState();
    previewModeDesignScreen = widget.firstLaunch
        ? FaceLabPreviewModeDesignScreen.firstLaunch
        : widget.creatingColleague
        ? FaceLabPreviewModeDesignScreen.createPerson
        : FaceLabPreviewModeDesignScreen.modifyPerson;
    final selfSex = FirstLaunchDesignDraft.parseSex(
      FirstLaunchDesignDraft.selfSex,
    );
    final colleagueSex = FirstLaunchDesignDraft.parseSex(
      FirstLaunchDesignDraft.colleagueSex,
    );
    configurationsDesignScreen[0]
      ..sex = selfSex
      ..hair = initialHairForSexDesignScreen(selfSex);
    configurationsDesignScreen[1]
      ..sex = colleagueSex
      ..hair = initialHairForSexDesignScreen(colleagueSex);
    if (!firstLaunchModeDesignScreen) targetDesignScreen = 1;
    syncAllAvatarDraftsDesignScreen();
  }

  void changePreviewModeDesignScreen(FaceLabPreviewModeDesignScreen mode) {
    setState(() {
      previewModeDesignScreen = mode;
      targetDesignScreen =
          mode == FaceLabPreviewModeDesignScreen.firstLaunch ||
              mode == FaceLabPreviewModeDesignScreen.modifySelf
          ? 0
          : 1;
      selfSavedDesignScreen = false;
      colleagueSavedDesignScreen = false;
      statusDesignScreen = null;
    });
  }

  DesignAvatarData avatarDataDesignScreen(_AvatarConfiguration value) {
    return DesignAvatarData(
      skinColor: avatarSkinColorsDesignScreen[value.skin],
      hairColor: avatarHairColorsDesignScreen[value.hairColor],
      outfitColor: avatarOutfitColorsDesignScreen[value.outfitColor],
      face: value.face,
      hair: value.hair,
      eyes: value.eyes,
      mouth: value.mouth,
      accessory: value.accessory,
    );
  }

  void syncAllAvatarDraftsDesignScreen() {
    DesignAvatarDraft.self = avatarDataDesignScreen(
      configurationsDesignScreen[0],
    );
    DesignAvatarDraft.firstColleague = avatarDataDesignScreen(
      configurationsDesignScreen[1],
    );
  }

  void updateAvatarDesignScreen(VoidCallback update) {
    setState(() {
      update();
      syncAllAvatarDraftsDesignScreen();
    });
  }

  void selectTargetDesignScreen(int target) {
    if (firstLaunchModeDesignScreen && target == 1 && !selfSavedDesignScreen) {
      return;
    }
    setState(() {
      targetDesignScreen = target;
      statusDesignScreen = null;
    });
  }

  void randomizeDesignScreen() {
    final random = Random();
    setState(() {
      configuration
        ..face = random.nextInt(20)
        ..skin = random.nextInt(20)
        ..hair = randomHairForSexDesignScreen(random, configuration.sex)
        ..hairColor = random.nextInt(20)
        ..eyes = random.nextInt(20)
        ..mouth = random.nextInt(20)
        ..accessory = random.nextInt(20)
        ..outfitColor = random.nextInt(20);
      syncAllAvatarDraftsDesignScreen();
      statusDesignScreen = 'New look generated';
    });
  }

  void saveDesignScreen() {
    setState(() {
      syncAllAvatarDraftsDesignScreen();
      if (!firstLaunchModeDesignScreen) {
        if (modifyingSelfDesignScreen) {
          selfSavedDesignScreen = true;
          statusDesignScreen = 'Changes to your avatar are ready';
          return;
        }
        colleagueSavedDesignScreen = true;
        statusDesignScreen = creatingPersonDesignScreen
            ? '$colleagueName’s avatar is ready to create'
            : 'Changes to $colleagueName’s avatar are ready';
        return;
      }
      if (targetDesignScreen == 0) {
        selfSavedDesignScreen = true;
        targetDesignScreen = 1;
        statusDesignScreen = 'Your avatar is ready. Now create $colleagueName';
      } else {
        colleagueSavedDesignScreen = true;
        statusDesignScreen = 'Both first-launch avatars are ready';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 380;
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: FirstLaunchHeroPanel(
                      onBack: () => context.go('/engineering'),
                      child: _AvatarPreviewPanel(
                        firstLaunch: firstLaunchModeDesignScreen,
                        creatingColleague: creatingPersonDesignScreen,
                        modifyingSelf: modifyingSelfDesignScreen,
                        colleagueName: colleagueName,
                        target: targetDesignScreen,
                        configuration: configuration,
                        compact: compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstLaunchModeDesignScreen
                                    ? 'Create two recognizable avatars'
                                    : modifyingSelfDesignScreen
                                    ? 'Modify your avatar'
                                    : creatingPersonDesignScreen
                                    ? 'Create $colleagueName’s avatar'
                                    : 'Modify $colleagueName’s avatar',
                                style: TextStyle(
                                  color: const Color(0xFF173F5D),
                                  fontSize: compact ? 18 : 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (!compact) ...[
                                const SizedBox(height: 3),
                                Text(
                                  firstLaunchModeDesignScreen
                                      ? 'Start with yourself, then create $colleagueName in your office.'
                                      : modifyingSelfDesignScreen
                                      ? 'Adjust your existing face, then save the changes.'
                                      : creatingPersonDesignScreen
                                      ? 'Create one recognizable face for this new colleague.'
                                      : 'Adjust this colleague’s existing face, then save the changes.',
                                  style: const TextStyle(
                                    color: Color(0xFF5E8196),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 5 : 9),
                        if (firstLaunchModeDesignScreen)
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  key: const ValueKey('avatar-target-self'),
                                  label: selfSavedDesignScreen
                                      ? '✓  You'
                                      : 'You',
                                  selected: targetDesignScreen == 0,
                                  leading: const Icon(Icons.person_rounded),
                                  onPressed: () => selectTargetDesignScreen(0),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppButton(
                                  key: const ValueKey(
                                    'avatar-target-colleague',
                                  ),
                                  label: colleagueSavedDesignScreen
                                      ? '✓  $colleagueName'
                                      : colleagueName,
                                  selected: targetDesignScreen == 1,
                                  leading: const Icon(Icons.people_alt_rounded),
                                  onPressed:
                                      selfSavedDesignScreen ||
                                          targetDesignScreen == 1
                                      ? () => selectTargetDesignScreen(1)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: compact ? 4 : 8),
                        Expanded(
                          child: GridView(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: compact ? 4 : 5,
                                  mainAxisExtent: compact ? 45 : 50,
                                ),
                            children: [
                              _FeaturePicker(
                                label: 'Face',
                                options: avatarFaceOptionsDesignScreen,
                                selected: configuration.face,
                                onSelected: (value) => updateAvatarDesignScreen(
                                  () => configuration.face = value,
                                ),
                              ),
                              _FeaturePicker(
                                label: 'Skin tone',
                                options: avatarSkinOptionsDesignScreen,
                                selected: configuration.skin,
                                colors: avatarSkinColorsDesignScreen,
                                onSelected: (value) => updateAvatarDesignScreen(
                                  () => configuration.skin = value,
                                ),
                              ),
                              _FeaturePicker(
                                label: 'Hair',
                                options: avatarHairOptionsDesignScreen,
                                selected: configuration.hair,
                                onSelected: (value) => updateAvatarDesignScreen(
                                  () => configuration.hair = value,
                                ),
                              ),
                              _FeaturePicker(
                                label: 'Hair color',
                                options: avatarHairColorOptionsDesignScreen,
                                selected: configuration.hairColor,
                                colors: avatarHairColorsDesignScreen,
                                onSelected: (value) => updateAvatarDesignScreen(
                                  () => configuration.hairColor = value,
                                ),
                              ),
                              _FeaturePicker(
                                label: 'Eyes',
                                options: avatarEyeOptionsDesignScreen,
                                selected: configuration.eyes,
                                onSelected: (value) => updateAvatarDesignScreen(
                                  () => configuration.eyes = value,
                                ),
                              ),
                              _FeaturePicker(
                                label: 'Mouth',
                                options: avatarMouthOptionsDesignScreen,
                                selected: configuration.mouth,
                                onSelected: (value) => updateAvatarDesignScreen(
                                  () => configuration.mouth = value,
                                ),
                              ),
                              _FeaturePicker(
                                label: 'Accessory',
                                options: avatarAccessoryOptionsDesignScreen,
                                selected: configuration.accessory,
                                onSelected: (value) => updateAvatarDesignScreen(
                                  () => configuration.accessory = value,
                                ),
                              ),
                              _FeaturePicker(
                                label: 'Outfit color',
                                options: avatarOutfitOptionsDesignScreen,
                                selected: configuration.outfitColor,
                                colors: avatarOutfitColorsDesignScreen,
                                onSelected: (value) => updateAvatarDesignScreen(
                                  () => configuration.outfitColor = value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 3 : 6),
                        Row(
                          children: [
                            if (statusDesignScreen != null)
                              Expanded(
                                child: Text(
                                  statusDesignScreen!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF337FA8),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            else
                              const Spacer(),
                            FirstLaunchBottomAction(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 135,
                                    child: AppButton(
                                      label: 'Randomize',
                                      onPressed: randomizeDesignScreen,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 200,
                                    child: AppButton(
                                      label:
                                          firstLaunchModeDesignScreen &&
                                              targetDesignScreen == 0
                                          ? 'Save & Create $colleagueName'
                                          : firstLaunchModeDesignScreen
                                          ? 'Finish Avatar Setup'
                                          : creatingPersonDesignScreen
                                          ? 'Create Colleague'
                                          : 'Save Changes',
                                      onPressed: saveDesignScreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            right: 16,
            child: _FaceLabModeTune(
              mode: previewModeDesignScreen,
              onChanged: changePreviewModeDesignScreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceLabModeTune extends StatelessWidget {
  const _FaceLabModeTune({required this.mode, required this.onChanged});

  final FaceLabPreviewModeDesignScreen mode;
  final ValueChanged<FaceLabPreviewModeDesignScreen> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('face-lab-mode-tune'),
      width: 150,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF65C5ED), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FaceLabPreviewModeDesignScreen>(
          value: mode,
          isExpanded: true,
          icon: const Icon(
            Icons.tune_rounded,
            size: 16,
            color: Color(0xFF318DB6),
          ),
          style: const TextStyle(
            color: Color(0xFF245672),
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
          items: const [
            DropdownMenuItem(
              value: FaceLabPreviewModeDesignScreen.firstLaunch,
              child: Text('First Launch'),
            ),
            DropdownMenuItem(
              value: FaceLabPreviewModeDesignScreen.modifySelf,
              child: Text('Modify Self'),
            ),
            DropdownMenuItem(
              value: FaceLabPreviewModeDesignScreen.modifyPerson,
              child: Text('Modify Person'),
            ),
            DropdownMenuItem(
              value: FaceLabPreviewModeDesignScreen.createPerson,
              child: Text('Create Person'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _AvatarPreviewPanel extends StatelessWidget {
  const _AvatarPreviewPanel({
    required this.firstLaunch,
    required this.creatingColleague,
    required this.modifyingSelf,
    required this.colleagueName,
    required this.target,
    required this.configuration,
    required this.compact,
  });

  final bool firstLaunch;
  final bool creatingColleague;
  final bool modifyingSelf;
  final String colleagueName;
  final int target;
  final _AvatarConfiguration configuration;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final self = target == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: SizedBox.square(
              dimension: compact ? 145 : 190,
              child: CustomPaint(
                key: ValueKey('avatar-preview-$target'),
                painter: DesignAvatarPainter(
                  DesignAvatarData(
                    skinColor: avatarSkinColorsDesignScreen[configuration.skin],
                    hairColor:
                        avatarHairColorsDesignScreen[configuration.hairColor],
                    outfitColor:
                        avatarOutfitColorsDesignScreen[configuration
                            .outfitColor],
                    face: configuration.face,
                    hair: configuration.hair,
                    eyes: configuration.eyes,
                    mouth: configuration.mouth,
                    accessory: configuration.accessory,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (firstLaunch) ...[
          Text(
            self ? 'Create your avatar' : 'Create $colleagueName’s avatar',
            style: TextStyle(
              color: const Color(0xFF174765),
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
        ],
        Text(
          self
              ? modifyingSelf
                    ? 'Adjust your existing character while keeping it recognizable on the office map.'
                    : 'Choose a simple, recognizable character to represent you in the office.'
              : firstLaunch
              ? 'Give $colleagueName a distinct look so they are easy to recognize on the office map.'
              : creatingColleague
              ? 'Create one distinct face for this new colleague.'
              : 'Modify this existing character while keeping them recognizable on the office map.',
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF56819A),
            fontSize: 9,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FeaturePicker extends StatefulWidget {
  const _FeaturePicker({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.colors,
  });

  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<Color>? colors;

  @override
  State<_FeaturePicker> createState() => _FeaturePickerState();
}

class _FeaturePickerState extends State<_FeaturePicker> {
  final ScrollController scrollControllerDesignScreen = ScrollController();

  @override
  void initState() {
    super.initState();
    revealSelectionDesignScreen(animate: false);
  }

  @override
  void didUpdateWidget(covariant _FeaturePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      revealSelectionDesignScreen(animate: true);
    }
  }

  void revealSelectionDesignScreen({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollControllerDesignScreen.hasClients) return;
      final position = scrollControllerDesignScreen.position;
      final target = (widget.selected * 27.0 - position.viewportDimension / 2)
          .clamp(0.0, position.maxScrollExtent);
      if (animate) {
        scrollControllerDesignScreen.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        scrollControllerDesignScreen.jumpTo(target);
      }
    });
  }

  @override
  void dispose() {
    scrollControllerDesignScreen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF65C5ED), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Color(0xFF315F79),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              key: ValueKey('avatar-${widget.label}-options'),
              controller: scrollControllerDesignScreen,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: widget.options.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) => _FeatureOption(
                key: ValueKey('avatar-${widget.label}-option-$index'),
                label: widget.options[index],
                shortLabel: widget.colors == null ? '${index + 1}' : null,
                color: widget.colors?[index],
                selected: widget.selected == index,
                onTap: () => widget.onSelected(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureOption extends StatelessWidget {
  const _FeatureOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.shortLabel,
    this.color,
  });

  final String label;
  final String? shortLabel;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 21,
          height: 21,
          decoration: BoxDecoration(
            color: color ?? (selected ? const Color(0xFFDDF3FF) : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? const Color(0xFF3C9EDD)
                  : const Color(0xFFB7D8E8),
              width: selected ? 3 : 1.5,
            ),
          ),
          child: color == null
              ? Center(
                  child: Text(
                    shortLabel ?? label.characters.first,
                    style: const TextStyle(
                      color: Color(0xFF39728F),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _AvatarConfiguration {
  _AvatarConfiguration({
    this.face = 0,
    this.skin = 1,
    this.hair = 0,
    this.hairColor = 0,
    this.eyes = 0,
    this.mouth = 0,
    this.accessory = 0,
    this.outfitColor = 0,
  });

  int face;
  int skin;
  int hair;
  int hairColor;
  int eyes;
  int mouth;
  int accessory;
  int outfitColor;
  AvatarSexDesignScreen sex = AvatarSexDesignScreen.unspecified;
}

int initialHairForSexDesignScreen(AvatarSexDesignScreen sex) {
  return switch (sex) {
    AvatarSexDesignScreen.female => 12,
    AvatarSexDesignScreen.male => 0,
    AvatarSexDesignScreen.unspecified => 0,
  };
}

int randomHairForSexDesignScreen(Random random, AvatarSexDesignScreen sex) {
  const feminineStyles = [2, 3, 5, 6, 9, 10, 11, 12, 13, 16, 17];
  const masculineStyles = [0, 1, 4, 7, 8, 14, 15, 18, 19];
  final choices = switch (sex) {
    AvatarSexDesignScreen.female => feminineStyles,
    AvatarSexDesignScreen.male => masculineStyles,
    AvatarSexDesignScreen.unspecified => null,
  };
  return choices == null
      ? random.nextInt(20)
      : choices[random.nextInt(choices.length)];
}

const avatarFaceOptionsDesignScreen = [
  'Round',
  'Oval',
  'Square',
  'Heart',
  'Long',
  'Soft',
  'Angular',
  'Wide',
  'Narrow',
  'Diamond',
  'Full',
  'Tapered',
  'Petite',
  'Broad',
  'Balanced',
  'High cheek',
  'Low cheek',
  'Strong jaw',
  'Soft jaw',
  'Custom',
];

const avatarSkinOptionsDesignScreen = [
  'Porcelain',
  'Ivory',
  'Warm ivory',
  'Beige',
  'Warm beige',
  'Sand',
  'Golden',
  'Honey',
  'Caramel',
  'Amber',
  'Tan',
  'Bronze',
  'Chestnut',
  'Umber',
  'Espresso',
  'Cool light',
  'Cool medium',
  'Warm medium',
  'Deep neutral',
  'Deep warm',
];

const avatarHairOptionsDesignScreen = [
  'Short',
  'Side part',
  'Curls',
  'Waves',
  'Buzz cut',
  'Bob',
  'Pixie',
  'Undercut',
  'Crew cut',
  'Afro',
  'Braids',
  'Bun',
  'Ponytail',
  'Locs',
  'Quiff',
  'Slick back',
  'Layered',
  'Bangs',
  'Mohawk',
  'Bald',
];

const avatarHairColorOptionsDesignScreen = [
  'Black',
  'Soft black',
  'Dark brown',
  'Brown',
  'Chestnut',
  'Auburn',
  'Copper',
  'Ginger',
  'Dark blonde',
  'Blonde',
  'Platinum',
  'Silver',
  'Grey',
  'White',
  'Burgundy',
  'Blue',
  'Teal',
  'Purple',
  'Pink',
  'Green',
];

const avatarEyeOptionsDesignScreen = [
  'Soft',
  'Alert',
  'Happy',
  'Focused',
  'Calm',
  'Wide',
  'Narrow',
  'Round',
  'Upturned',
  'Downturned',
  'Deep set',
  'Bright',
  'Serious',
  'Kind',
  'Confident',
  'Curious',
  'Relaxed',
  'Sharp',
  'Gentle',
  'Neutral',
];

const avatarMouthOptionsDesignScreen = [
  'Smile',
  'Calm',
  'Bright',
  'Neutral',
  'Grin',
  'Soft smile',
  'Wide smile',
  'Closed',
  'Confident',
  'Serious',
  'Friendly',
  'Relaxed',
  'Small',
  'Full',
  'Upturned',
  'Straight',
  'Open',
  'Cheerful',
  'Thoughtful',
  'Custom',
];

const avatarAccessoryOptionsDesignScreen = [
  'None',
  'Round glasses',
  'Headset',
  'Hair pin',
  'Square glasses',
  'Earbuds',
  'Cap',
  'Scarf',
  'Earrings',
  'Tie',
  'Bow tie',
  'Necklace',
  'Badge',
  'Lanyard',
  'Beret',
  'Headband',
  'Sunglasses',
  'Monocle',
  'Hearing aid',
  'Brooch',
];

const avatarOutfitOptionsDesignScreen = [
  'Ocean blue',
  'Royal purple',
  'Coral',
  'Emerald',
  'Amber',
  'Navy',
  'Sky blue',
  'Lavender',
  'Rose',
  'Mint',
  'Teal',
  'Indigo',
  'Red',
  'Orange',
  'Yellow',
  'Green',
  'Cyan',
  'Plum',
  'Brown',
  'Slate',
];

const avatarSkinColorsDesignScreen = [
  Color(0xFFFFE4D2),
  Color(0xFFFFD9BE),
  Color(0xFFFBD0AF),
  Color(0xFFF3BE96),
  Color(0xFFEAB184),
  Color(0xFFE2A477),
  Color(0xFFD99568),
  Color(0xFFCE895D),
  Color(0xFFC27D52),
  Color(0xFFB67249),
  Color(0xFFAE6E48),
  Color(0xFFA26240),
  Color(0xFF96583A),
  Color(0xFF894F35),
  Color(0xFF75452F),
  Color(0xFFF6C9AD),
  Color(0xFFD8A080),
  Color(0xFFC58863),
  Color(0xFF824D38),
  Color(0xFF643A2A),
];

const avatarHairColorsDesignScreen = [
  Color(0xFF263D4D),
  Color(0xFF342B2B),
  Color(0xFF4A332C),
  Color(0xFF6A4435),
  Color(0xFF87563A),
  Color(0xFF9E5038),
  Color(0xFFB96538),
  Color(0xFFD0773E),
  Color(0xFFB98A52),
  Color(0xFFD29B4B),
  Color(0xFFE7C47B),
  Color(0xFFBEC4CC),
  Color(0xFF858C96),
  Color(0xFFF2EEE5),
  Color(0xFF7D3448),
  Color(0xFF356FA8),
  Color(0xFF318C91),
  Color(0xFF8B6BAE),
  Color(0xFFC65E8D),
  Color(0xFF4B9263),
];

const avatarOutfitColorsDesignScreen = [
  Color(0xFF3299D0),
  Color(0xFF685BC7),
  Color(0xFFDD7D67),
  Color(0xFF4DA988),
  Color(0xFFD39B42),
  Color(0xFF274C77),
  Color(0xFF72BCE0),
  Color(0xFFA78BDB),
  Color(0xFFD9788D),
  Color(0xFF88C9A1),
  Color(0xFF2B8E91),
  Color(0xFF4B5EC7),
  Color(0xFFC94F5C),
  Color(0xFFE88745),
  Color(0xFFE2C14F),
  Color(0xFF579D59),
  Color(0xFF46AFC2),
  Color(0xFF8D4E8D),
  Color(0xFF805A45),
  Color(0xFF647687),
];

// Legacy painter retained temporarily for visual comparison while the shared
// DesignAvatarPainter is used by Face Lab and People Network.
// ignore: unused_element
class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.configuration);

  final _AvatarConfiguration configuration;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide / 200;
    canvas.save();
    canvas.scale(scale);
    final c = Offset(center.dx / scale, center.dy / scale);

    canvas.drawCircle(
      Offset(c.dx, 105),
      88,
      Paint()..color = const Color(0xFFE5F6FF),
    );
    canvas.drawOval(
      const Rect.fromLTWH(45, 154, 110, 35),
      Paint()
        ..color = avatarOutfitColorsDesignScreen[configuration.outfitColor],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(86, 128, 28, 35),
        const Radius.circular(9),
      ),
      Paint()..color = avatarSkinColorsDesignScreen[configuration.skin],
    );

    final hairStyle = configuration.hair;
    final hairPaint = Paint()
      ..color = avatarHairColorsDesignScreen[configuration.hairColor];
    if (hairStyle == 5 || hairStyle == 16) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(50, 29, 100, 132),
          const Radius.circular(43),
        ),
        hairPaint,
      );
    } else if (hairStyle == 10 || hairStyle == 13) {
      final strands = Paint()
        ..color = hairPaint.color
        ..strokeWidth = hairStyle == 10 ? 9 : 7
        ..strokeCap = StrokeCap.round;
      for (var index = 0; index < 4; index++) {
        canvas.drawLine(
          Offset(62 + index * 5, 71),
          Offset(54 + index * 5, 151 - index * 4),
          strands,
        );
        canvas.drawLine(
          Offset(138 - index * 5, 71),
          Offset(146 - index * 5, 151 - index * 4),
          strands,
        );
      }
    } else if (hairStyle == 11) {
      canvas.drawCircle(const Offset(100, 27), 24, hairPaint);
    } else if (hairStyle == 12) {
      canvas.drawOval(const Rect.fromLTWH(128, 48, 48, 105), hairPaint);
    }

    final faceVariant = configuration.face % 5;
    final faceRect = switch (faceVariant) {
      1 => const Rect.fromLTWH(61, 39, 78, 105),
      2 => const Rect.fromLTWH(58, 43, 84, 96),
      3 => const Rect.fromLTWH(60, 40, 80, 101),
      4 => const Rect.fromLTWH(56, 45, 88, 93),
      _ => const Rect.fromLTWH(58, 42, 84, 96),
    };
    final radius = faceVariant == 2
        ? 23.0
        : faceVariant == 3
        ? 34.0
        : 42.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(radius)),
      Paint()..color = avatarSkinColorsDesignScreen[configuration.skin],
    );

    if (hairStyle != 19) {
      final hairPath = Path()
        ..moveTo(60, 78)
        ..quadraticBezierTo(58, 34, 101, 31)
        ..quadraticBezierTo(143, 35, 140, 79)
        ..quadraticBezierTo(
          118,
          61 - (hairStyle % 5) * 3,
          60,
          78 + (hairStyle % 5) * 2,
        )
        ..close();
      canvas.drawPath(hairPath, hairPaint);
    }
    if (hairStyle == 17) {
      final bangs = Paint()
        ..color = hairPaint.color
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round;
      for (var index = 0; index < 5; index++) {
        canvas.drawLine(
          Offset(76 + index * 12, 55),
          Offset(73 + index * 12, 78 + (index.isEven ? 5 : 0)),
          bangs,
        );
      }
    }

    final eyePaint = Paint()
      ..color = const Color(0xFF27485A)
      ..strokeWidth = configuration.eyes % 3 == 1 ? 4 : 3
      ..strokeCap = StrokeCap.round;
    if (configuration.eyes % 3 == 2) {
      canvas.drawArc(
        const Rect.fromLTWH(75, 85, 16, 10),
        0,
        pi,
        false,
        eyePaint..style = PaintingStyle.stroke,
      );
      canvas.drawArc(
        const Rect.fromLTWH(109, 85, 16, 10),
        0,
        pi,
        false,
        eyePaint,
      );
    } else {
      canvas.drawCircle(const Offset(83, 91), 3.5, eyePaint);
      canvas.drawCircle(const Offset(117, 91), 3.5, eyePaint);
    }

    final mouthPaint = Paint()
      ..color = const Color(0xFFB65E67)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    if (configuration.mouth % 3 == 1) {
      canvas.drawLine(
        const Offset(92, 119),
        const Offset(108, 119),
        mouthPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromLTWH(89, configuration.mouth % 3 == 2 ? 108 : 111, 22, 16),
        0.15,
        pi - 0.3,
        false,
        mouthPaint,
      );
    }

    final accessoryVariant = configuration.accessory % 4;
    if (accessoryVariant == 1) {
      final glasses = Paint()
        ..color = const Color(0xFF4A7790)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(const Offset(83, 92), 10, glasses);
      canvas.drawCircle(const Offset(117, 92), 10, glasses);
      canvas.drawLine(const Offset(93, 92), const Offset(107, 92), glasses);
    } else if (accessoryVariant == 2) {
      final headset = Paint()
        ..color = const Color(0xFF6657B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawArc(
        const Rect.fromLTWH(54, 47, 92, 92),
        pi,
        pi,
        false,
        headset,
      );
      canvas.drawCircle(
        const Offset(143, 105),
        7,
        headset..style = PaintingStyle.fill,
      );
    } else if (accessoryVariant == 3) {
      canvas.drawCircle(
        const Offset(133, 65),
        7,
        Paint()..color = const Color(0xFFA184F0),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) => true;
}
