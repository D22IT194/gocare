import 'package:flutter/material.dart';

import '../models/doctor_filter_model.dart';

class DoctorFilterSheet
    extends StatefulWidget {
  const DoctorFilterSheet({
    super.key,
    required this.initialFilter,
  });

  final DoctorFilterModel initialFilter;

  @override
  State<DoctorFilterSheet>
      createState() =>
          _DoctorFilterSheetState();
}

class _DoctorFilterSheetState
    extends State<
        DoctorFilterSheet> {
  late double? _rating;
  late int? _experience;
  late double? _fee;

  late bool _availableToday;
  late bool _verified;
  late bool _appointment;

  @override
  void initState() {
    super.initState();

    final filter =
        widget.initialFilter;

    _rating =
        filter.minRating;

    _experience =
        filter.minExperienceYears;

    _fee =
        filter.maxConsultationFee;

    _availableToday =
        filter.availableToday;

    _verified =
        filter.verifiedOnly;

    _appointment =
        filter.appointmentAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter Doctors',
                      style:
                          TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(
                          0xFF172B4D,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = null;
                        _experience = null;
                        _fee = null;
                        _availableToday =
                            false;
                        _verified = false;
                        _appointment =
                            false;
                      });
                    },
                    icon:
                        const Icon(
                      Icons
                          .restart_alt_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Minimum Rating',
                style:
                    TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF344054),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Wrap(
                spacing: 8,
                children: [
                  3.0,
                  4.0,
                  4.5,
                  4.8,
                ].map(
                  (value) {
                    final selected =
                        _rating ==
                            value;

                    return ChoiceChip(
                      label: Text(
                        '$value+ ⭐',
                      ),
                      selected:
                          selected,
                      onSelected:
                          (_) {
                        setState(() {
                          _rating =
                              selected
                                  ? null
                                  : value;
                        });
                      },
                    );
                  },
                ).toList(),
              ),

              const SizedBox(
                height: 22,
              ),

              const Text(
                'Experience',
                style:
                    TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF344054),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Wrap(
                spacing: 8,
                children: [
                  5,
                  10,
                  15,
                  20,
                ].map(
                  (value) {
                    final selected =
                        _experience ==
                            value;

                    return ChoiceChip(
                      label: Text(
                        '$value+ years',
                      ),
                      selected:
                          selected,
                      onSelected:
                          (_) {
                        setState(() {
                          _experience =
                              selected
                                  ? null
                                  : value;
                        });
                      },
                    );
                  },
                ).toList(),
              ),

              const SizedBox(
                height: 22,
              ),

              const Text(
                'Maximum Consultation Fee',
                style:
                    TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF344054),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Wrap(
                spacing: 8,
                children: [
                  300.0,
                  500.0,
                  1000.0,
                  1500.0,
                ].map(
                  (value) {
                    final selected =
                        _fee ==
                            value;

                    return ChoiceChip(
                      label:
                          Text(
                        '₹${value.toInt()}',
                      ),
                      selected:
                          selected,
                      onSelected:
                          (_) {
                        setState(() {
                          _fee =
                              selected
                                  ? null
                                  : value;
                        });
                      },
                    );
                  },
                ).toList(),
              ),

              const SizedBox(
                height: 16,
              ),

              SwitchListTile(
                contentPadding:
                    EdgeInsets.zero,
                title:
                    const Text(
                  'Available today',
                ),
                value:
                    _availableToday,
                onChanged:
                    (value) {
                  setState(() {
                    _availableToday =
                        value;
                  });
                },
              ),

              SwitchListTile(
                contentPadding:
                    EdgeInsets.zero,
                title:
                    const Text(
                  'Verified doctors only',
                ),
                value:
                    _verified,
                onChanged:
                    (value) {
                  setState(() {
                    _verified =
                        value;
                  });
                },
              ),

              SwitchListTile(
                contentPadding:
                    EdgeInsets.zero,
                title:
                    const Text(
                  'Appointment available',
                ),
                value:
                    _appointment,
                onChanged:
                    (value) {
                  setState(() {
                    _appointment =
                        value;
                  });
                },
              ),

              const SizedBox(
                height: 18,
              ),

              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DoctorFilterModel(
                        minRating:
                            _rating,
                        minExperienceYears:
                            _experience,
                        maxConsultationFee:
                            _fee,
                        availableToday:
                            _availableToday,
                        verifiedOnly:
                            _verified,
                        appointmentAvailable:
                            _appointment,
                      ),
                    );
                  },
                  child:
                      const Text(
                    'Apply Filters',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}