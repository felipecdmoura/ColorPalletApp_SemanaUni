import 'dart:ffi';
import 'dart:math';

import 'package:color_palette_app_semana_uni/bloc/color_form_bloc/color_form_bloc.dart';
import 'package:color_palette_app_semana_uni/bloc/color_form_bloc/color_form_bloc_state.dart';
import 'package:color_palette_app_semana_uni/bloc/color_palette_bloc/color_palette_bloc.dart';
import 'package:color_palette_app_semana_uni/bloc/color_palette_bloc/color_palette_bloc_events.dart';
import 'package:color_palette_app_semana_uni/bloc/color_palette_bloc/color_palette_bloc_state.dart';
import 'package:color_palette_app_semana_uni/views/create_color_palette_screen.dart';
import 'package:color_palette_app_semana_uni/views/empty_color_palette_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListColorPalettes extends StatefulWidget {
  const ListColorPalettes({ Key? key }) : super(key: key);

  @override
  _ListColorPalettesState createState() => _ListColorPalettesState();
}

class _ListColorPalettesState extends State<ListColorPalettes> {
  @override
  void initState(){
    super.initState();
    BlocProvider.of <ColorPaletteBloc>(context).add(ColorPaletteFetchList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suas Paletas de Cores',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 10,
        backgroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<ColorPaletteBloc>(context), //Passa o Bloc ColorPaletteBloc do main para esta tela
                  ),

                  //Gera o bloc ColorFormBloc, a ser usado na criacao de novas paletas
                  BlocProvider<ColorFormBloc>(
                    create: (_) => ColorFormBloc(
                      //Sem id pois e uma nova paleta sendo gerada
                      ColorFormState(
                        id: '',
                        colors: List.generate(5, (index) => Random().nextInt(0xffffffff)), //Gera uma lista de cores aleatorias
                        title: 'Nova Paleta')),
                  )                  
                ],
                child: CreateColorPaletteScreen(editing: false),
              );
            }
          ));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.grey,
      ),
      backgroundColor: Colors.white,
      body: BlocBuilder<ColorPaletteBloc, ColorPaletteState>(
        builder: (context, state){
          ColorPaletteBloc bloc = BlocProvider.of<ColorPaletteBloc>(context);
          if(state is ColorPaletteLoading){
            return const CircularProgressIndicator(color: Colors.black,);
          }else if(state is ColorPaletteLoaded){
            return ListView.builder(
              itemCount: state.list.length,
              itemBuilder: (context, index){
                return ListTile(
                  title: Text(
                    state.list[index].title,
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  trailing: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                  tileColor: Colors.white,
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_){
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: BlocProvider.of<ColorPaletteBloc>(context)
                            ),

                            BlocProvider<ColorFormBloc>(create: (context){
                              List<int> paletteColorList = state.list[index].colors;
                              String paletteTitle = state.list[index].title;
                              String paletteId = state.list[index].id;

                              return ColorFormBloc(ColorFormState(
                                colors:paletteColorList,
                                title: paletteTitle,
                                id: paletteId));
                            }),
                          ], 
                          child: CreateColorPaletteScreen(editing: true)
                        );
                      },
                    ));
                  },
                  contentPadding: EdgeInsets.all(10),
                  subtitle: Container(
                    child: 
                      Row(children: colorCircles(state.list[index].colors)),
                  ),
                );
              },
            );
          }else if(state is ColorPaletteAdded || state is ColorPaletteEdited){
            bloc.add(ColorPaletteFetchList());
            return Container();
          }else if(state is ColorPaletteEmptyList){
            return const EmptyListScreen();
          }else if(state is ColorPaletteErrorState){
            return Text(state.message);
          }else{
            print("Estado nao Implementado!");
            return Container();
          }
        },
      ),
    );
  }

  List<Widget> colorCircles(List<int> colors) {
    List<Widget> circleslist = [];

    for (var i = 0; i < 5; i++) {
      Widget circle = Padding(
        padding: const EdgeInsets.all(5),
        child: CircleAvatar(
          backgroundColor: Color(colors[i]).withAlpha(0xff),
          radius: 10
        ),
      );
      circleslist.add(circle);
    }

    return circleslist;
  }
}