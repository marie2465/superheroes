import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:http/http.dart' as http;

import '../widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  final http.Client? client;
  MainPage({Key? key, this.client}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc(client:  widget.client);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainPageStateWidget(),
        const SearchWidget(),
      ],
    );
  }
}

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController controller = TextEditingController();
  bool haveSearchedText = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
      controller.addListener(() {
        bloc.updateText(controller.text);
        final haveText = controller.text.isNotEmpty;
        if (haveSearchedText != haveText) {
          setState(() {
            haveSearchedText = haveText;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 20,
          color: Colors.white,
        ),
        cursorColor: Colors.white,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          filled: true,
          fillColor: SuperheroesColors.indigo75,
          isDense: true,
          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 24),
          suffix: GestureDetector(
            onTap: () => controller.clear(),
            child: const Icon(Icons.clear, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: haveSearchedText
                ? BorderSide(color: Colors.white, width: 2)
                : BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return const LoadingIndicator();
          case MainPageState.noFavorites:
            return Stack(
              children: [
                const NoFavorites(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ActionButton(
                      text: "Remove", onTap: () => bloc.removeFavorite()),
                ),
              ],
            );
          case MainPageState.minSymbols:
            return const MinSymbols();
          case MainPageState.searchResults:
            return SuperheroesList(
                title: "Search results",
                stream: bloc.observeSearchedSuperheroes());
          case MainPageState.favorites:
            return Stack(
              children: [
                SuperheroesList(
                    title: "Your favorites",
                    stream: bloc.observeFavoriteSuperheroes()),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: ActionButton(
                        text: "Remove", onTap: () => bloc.removeFavorite()))
              ],
            );
          case MainPageState.nothingFound:
            return const NothingFound();
          case MainPageState.loadingError:
            return const LoadingError();
          default:
            return Center(
                child: Text(
              snapshot.data!.toString(),
              style: const TextStyle(color: Colors.white),
            ));
        }
      },
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          color: SuperheroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class MinSymbols extends StatelessWidget {
  const MinSymbols({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: Text(
          "Enter at least 3 symbols",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class NoFavorites extends StatelessWidget {
  const NoFavorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InfoWithButton(
        title: "No favorites yet",
        subtitle: "Search and add",
        buttonText: "Search",
        assetImage: SuperheroesImages.ironman,
        imageHeight: 119,
        imageWidth: 108,
        imageTopPadding: 9,
      ),
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;

  const SuperheroesList({
    Key? key,
    required this.title,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuperheroInfo>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final List<SuperheroInfo> superheroes = snapshot.data!;
          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: superheroes.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 90, bottom: 12),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              final SuperheroInfo item = superheroes[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SuperheroCard(
                  superheroInfo: item,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SuperheroPage(
                              name: item.name,
                            )));
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 8);
            },
          );
        });
  }
}

class NothingFound extends StatelessWidget {
  const NothingFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InfoWithButton(
        title: "Nothing found",
        subtitle: "Search for something else",
        buttonText: "Search",
        assetImage: SuperheroesImages.hulk,
        imageHeight: 112,
        imageWidth: 84,
        imageTopPadding: 16,
      ),
    );
  }
}

class LoadingError extends StatelessWidget {
  const LoadingError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InfoWithButton(
        title: "Error happened",
        subtitle: "Please, try again",
        buttonText: "Retry",
        assetImage: SuperheroesImages.superman,
        imageHeight: 106,
        imageWidth: 126,
        imageTopPadding: 22,
      ),
    );
  }
}
