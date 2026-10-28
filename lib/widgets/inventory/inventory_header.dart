import 'package:flutter/material.dart';
import 'package:service_application_1/widgets_style/btns.dart';
import 'package:service_application_1/widgets_style/colors.dart';
import 'package:service_application_1/widgets_style/typographick.dart';
import 'package:service_application_1/widgets/inventory/add_product_dialog.dart';
import 'package:service_application_1/widgets/inventory/inventory_search_bar.dart';

class InventoryHeader extends StatefulWidget {
  // پس از ثبت محصول، صفحه انبار را به‌روزرسانی می‌کند.
  final VoidCallback? onProductAdded;

  // کنترل‌کننده کادر جست‌وجو که از صفحه انبار دریافت می‌شود.
  final TextEditingController searchController;

  // متن جست‌وجو را به صفحه انبار ارسال می‌کند.
  final ValueChanged<String>? onSearchChanged;

  const InventoryHeader({
    super.key,
    this.onProductAdded,
    required this.searchController,
    this.onSearchChanged,
  });

  @override
  State<InventoryHeader> createState() => _InventoryHeaderState();
}

class _InventoryHeaderState extends State<InventoryHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          // =========================================
          // بخش بالایی: صفحه اصلی، افزودن محصول و داشبورد
          // =========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (MediaQuery.sizeOf(context).width > 580) {
                    return SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: Buttons.normalbtn,
                        onPressed: () {},
                        child: SizedBox(
                          height: 24,
                          child: Row(children: [
                            Text(
                            'صفحه اصلی',
                            style: AppTextStyle.titleLarge.copyWith(
                              color: Basicolor.basic01,
                            ),
                          ),
                          SizedBox(width: 8,),
                          Icon(Icons.home,size: 27,)
                          ],),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          overlayColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              width: 1,
                              color: Basicolor.basic10,
                            ),
                          ),
                        ),
                        onPressed: () {},
                        icon: Icon(
                          Icons.home,
                          size: 24,
                          color: WidgetStateColor.resolveWith((states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.white;
                            }
                            return Basicolor.basic03;
                          }),
                        ),
                      ),
                    );
                  }
                },
              ),

              Row(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (MediaQuery.sizeOf(context).width > 580) {
                        return SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Prime.prime,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                                side: BorderSide(width: 1, color: Prime.prime),
                              ),
                            ),
                            onPressed: () async {
                              final added = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const AddProductDialog(),
                              );

                              // اگر محصول ثبت شد، فهرست انبار به‌روزرسانی شود.
                              if (added == true) {
                                widget.onProductAdded?.call();
                              }
                            },
                            child: SizedBox(
                              height: 24,
                              child: Text(
                                'افزودن محصول جدید',
                                style: AppTextStyle.titleLarge.copyWith(
                                  color: Basicolor.basic11,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            style: IconButton.styleFrom(
                              overlayColor: Colors.transparent,
                              backgroundColor: Prime.prime
                            ),
                            onPressed: () async {
                              final added = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const AddProductDialog(),
                              );
                              
                              // اگر محصول ثبت شد، فهرست انبار به‌روزرسانی شود.
                              if (added == true) {
                                widget.onProductAdded?.call();
                              }
                            },
                            icon: Icon(Icons.add,size: 24,color: Colors.white,),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(width: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (MediaQuery.sizeOf(context).width > 580) {
                        return SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: Buttons.normalbtn,
                            onPressed: () {},
                            child: Row(
                              children: [
                                Text("داشبورد",style: TextStyle(fontFamily: "kalame",fontSize: 16,fontWeight: FontWeight.w600),),
                                SizedBox(width: 4,),
                                Icon(
                                  Icons.dashboard,
                                  size: 27,
                                  color: Basicolor.basic03
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                             style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          overlayColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              width: 1,
                              color: Basicolor.basic10,
                            ),
                          ),
                        ),
                            onPressed: () {},
                            icon: Icon(Icons.dashboard),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 34),

          // =========================================
          // بخش جست‌وجو و تعداد محصولات
          // =========================================
          SizedBox(
              width: 333,
              height: 40,
              child: InventorySearchBar(
              controller: widget.searchController,
              onChanged: widget.onSearchChanged,
            ),
         ),
        ],
      ),
    );
  }
}
