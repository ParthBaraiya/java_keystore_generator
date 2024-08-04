import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

const _defaultFullName = "John Doe";
const _defaultOrganizationalUnit = "N/A";
const _defaultOrganization = "Pvt. Ltd.";
const _defaultCity = "N/A";
const _defaultState = "N/A";
const _defaultCountryCode = "N/A";
const _defaultValidity = "10000";

class KeystoreForm extends StatefulWidget {
  const KeystoreForm({super.key});

  @override
  State<KeystoreForm> createState() => _KeystoreFormState();
}

class _KeystoreFormState extends State<KeystoreForm> {
  final _isExpanded = ValueNotifier(false);
  final _filePath = ValueNotifier('');

  final _name = TextEditingController();
  final _storePassword = TextEditingController();
  final _alias = TextEditingController();
  final _validity = TextEditingController(text: _defaultValidity);
  final _fullName = TextEditingController(text: _defaultFullName);
  final _organizationalUnit =
      TextEditingController(text: _defaultOrganizationalUnit);
  final _organization = TextEditingController(text: _defaultOrganization);
  final _city = TextEditingController(text: _defaultCity);
  final _state = TextEditingController(text: _defaultState);
  final _countryCode = TextEditingController(text: _defaultCountryCode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Generate Keystore for Android apps",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 30),
            DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  )),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Keystore Name *",
                            ),
                            controller: _name,
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Folder for generated keystore *',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final String? directoryPath =
                                          await getDirectoryPath(
                                        confirmButtonText: 'Choose',
                                      );

                                      if (directoryPath != null) {
                                        _filePath.value = directoryPath;
                                        return;
                                      } else {
                                        context
                                            .showSnackbar("No path selected.");
                                      }
                                    },
                                    child: const Text("Select"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ListenableBuilder(
                      listenable: _filePath + _name,
                      builder: (_, __) {
                        if (_filePath.value.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Row(
                          children: [
                            Flexible(
                              child: Text(_filePath.value),
                            ),
                            Text(Platform.pathSeparator),
                            Flexible(child: Text('${_name.text}.keystore')),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    InputItem(
                      title: 'Keystore Password *',
                      controller: _storePassword,
                    ),
                    InputItem(
                      title: 'Keystore Alias *',
                      controller: _alias,
                    ),
                    InputItem(
                      title: 'Validity (Days) *',
                      controller: _validity,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      type: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                _isExpanded.value = !_isExpanded.value;
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Advanced Options",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _isExpanded,
              builder: (_, value, child) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child:
                      value ? child : const SizedBox(width: double.maxFinite),
                );
              },
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  InputItem(
                    title: 'Full Name',
                    controller: _fullName,
                  ),
                  InputItem(
                    title: 'Organizational Unit',
                    controller: _organizationalUnit,
                  ),
                  InputItem(
                    title: 'Organization',
                    controller: _organization,
                  ),
                  InputItem(
                    title: 'City',
                    controller: _city,
                  ),
                  InputItem(
                    title: 'State',
                    controller: _state,
                  ),
                  InputItem(
                    title: 'Country Code',
                    controller: _countryCode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _generateKeyStore(),
                child: const Text("Generate Keystore"),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isExpanded.dispose();
    _name.dispose();
    _storePassword.dispose();
    _alias.dispose();
    _validity.dispose();
    _fullName.dispose();
    _organizationalUnit.dispose();
    _organization.dispose();
    _city.dispose();
    _state.dispose();
    _countryCode.dispose();

    super.dispose();
  }

  Future<void> _generateKeyStore() async {
    if (_name.text.trim().isEmpty) {
      context.showSnackbar('Keystore name is required');
      return;
    }

    if (_storePassword.text.trim().isEmpty) {
      context.showSnackbar('Keystore password is required');
      return;
    }

    if (_alias.text.trim().isEmpty) {
      context.showSnackbar('Keystore alias is required');
      return;
    }

    if (_validity.text.trim().isEmpty) {
      context.showSnackbar('Keytool validity is required');
      return;
    }

    if ((int.tryParse(_validity.text.trim()) ?? 0) <= 1) {
      context.showSnackbar('Validity must be more than 1 years');
      return;
    }

    final fileName = '${_name.text.trim()}.keystore';
    final alias = _alias.text.trim();
    final password = _storePassword.text.trim();
    final validity = _validity.text.trim();
    final fullName = _fullName.text.trim().isEmpty
        ? _defaultFullName
        : _fullName.text.trim();
    final orgUnit = _organizationalUnit.text.trim().isEmpty
        ? _defaultOrganizationalUnit
        : _organizationalUnit.text.trim();
    final org = _organization.text.trim().isEmpty
        ? _defaultOrganization
        : _organization.text.trim();
    final city = _city.text.trim().isEmpty ? _defaultCity : _city.text.trim();
    final state =
        _state.text.trim().isEmpty ? _defaultState : _state.text.trim();
    final countryCode = _countryCode.text.trim().isEmpty
        ? _defaultCountryCode
        : _countryCode.text.trim();

    try {
      final process = await Process.run('keytool', [
        '-genkey',
        '-v',
        '-keystore',
        (path.join(_filePath.value, fileName)),
        '-alias',
        alias,
        '-keyalg',
        'RSA',
        '-keysize',
        '2048',
        '-validity',
        validity,
        '-dname',
        'CN=$fullName, OU=$orgUnit, O=$org, L=$city, ST=$state, C=$countryCode',
        '-storepass',
        password,
        '-keypass',
        password,
      ]);

      context.showSnackbar('${process.stdout}');

      context.showSnackbar('Keystore generated...');
    } catch (e) {
      context.showSnackbar('$e');
    }
  }
}

class InputItem extends StatelessWidget {
  const InputItem({
    super.key,
    required this.title,
    required this.controller,
    this.type = TextInputType.text,
    this.inputFormatters,
  });

  final String title;
  final TextEditingController controller;
  final TextInputType type;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            )),
        Expanded(
          flex: 7,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter $title',
            ),
            inputFormatters: inputFormatters,
            keyboardType: type,
            controller: controller,
          ),
        ),
      ],
    );
  }
}

extension AddExtension on Listenable {
  Listenable operator +(Listenable listenable) {
    return Listenable.merge([this, listenable]);
  }
}

extension ScaffoldExtension on BuildContext {
  void showSnackbar(String message) {
    if (mounted) return;

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
