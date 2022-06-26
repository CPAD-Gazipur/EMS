import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/config/app_colors.dart';
import 'package:ems/service/payment/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckOutScreen extends StatefulWidget {
  final DocumentSnapshot eventData;
  const CheckOutScreen({Key? key, required this.eventData}) : super(key: key);

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  String eventImage = '';
  int serviceFee = 2;
  int totalTicket = 1;
  int selectedPaymentMethod = 0;

  void setSelectedPaymentMethod(int value) {
    setState(() {
      selectedPaymentMethod = value;
    });
  }

  @override
  void initState() {
    super.initState();

    try {
      List media = widget.eventData.get('event_media') as List;
      Map mediaMap =
          media.firstWhere((element) => element['isImage'] == true) as Map;
      eventImage = mediaMap['url'];
    } catch (e) {
      eventImage = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 27,
                    width: 27,
                    padding: const EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(
                        Icons.cancel_outlined,
                        size: 27,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(
                    height: 27,
                    child: Text(
                      'Checkout',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor2),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: Get.width,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF393939).withOpacity(0.15),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: eventImage,
                      fit: BoxFit.contain,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => const SizedBox(
                        width: 100,
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
                          width: 100,
                          height: 150,
                          child: Center(child: Icon(Icons.error))),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.eventData.get('event_name'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                widget.eventData
                                    .get('event_date')
                                    .toString()
                                    .split(',')[0],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.black54,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.eventData.get('event_location'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.activeColor,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              Text(
                                '${widget.eventData.get('event_date')}  |  ${widget.eventData.get('event_start_time')} - ${widget.eventData.get('event_end_time')}',
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.activeColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.04),
              const Spacer(),
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Divider(thickness: 2),
              InkWell(
                onTap: () {
                  setSelectedPaymentMethod(0);
                },
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      width: 48,
                      height: 34,
                      child: Image.asset(
                        'assets/images/stripe.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Text(
                      'Stripe',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Radio(
                      value: 0,
                      groupValue: selectedPaymentMethod,
                      onChanged: (int? value) {
                        setSelectedPaymentMethod(value!);
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setSelectedPaymentMethod(1);
                },
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      width: 48,
                      height: 34,
                      child: Image.asset(
                        'assets/images/paypal.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Text(
                      'PayPal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Radio(
                      value: 1,
                      groupValue: selectedPaymentMethod,
                      onChanged: (int? value) {
                        setSelectedPaymentMethod(value!);
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 2),
              Row(
                children: [
                  const Text(
                    'Event Fee',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$ ${widget.eventData.get('event_price')}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Total Ticket',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (totalTicket > 1) {
                        setState(() {
                          totalTicket--;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Must have to book 1 ticket'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.remove_circle),
                  ),
                  Text(
                    '$totalTicket',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (totalTicket < 5) {
                        setState(() {
                          totalTicket++;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Can\'t book more then 5 ticket'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_circle),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Service Fee',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$ $serviceFee',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$ ${(int.parse(widget.eventData.get('event_price')) * totalTicket) + serviceFee}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: InkWell(
                  onTap: () {
                    if (selectedPaymentMethod == 0) {
                      makePayment(
                        context,
                        amount:
                            '${(int.parse(widget.eventData.get('event_price')) * totalTicket) + serviceFee}',
                        eventID: widget.eventData.id,
                        totalTicket: totalTicket,
                      );
                    } else if (selectedPaymentMethod == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('PayPal is not available right now!')));
                    }
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
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
