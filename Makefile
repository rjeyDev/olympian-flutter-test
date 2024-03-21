
gen:
	flutter packages pub run build_runner build

ios:
	flutter build ipa

android:
	flutter build appbundle --no-shrink