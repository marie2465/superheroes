import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/info_with_button.dart';

import '../widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  final http.Client? client;

  const MainPage({Key? key, this.client}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc(client: widget.client);
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
  final FocusNode searchFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainPageStateWidget(
          searchFieldFocusNode: searchFieldFocusNode,
        ),
        SearchWidget(
          searchFieldFocusNode: searchFieldFocusNode,
        ),
      ],
    );
  }
}

class SearchWidget extends StatefulWidget {
  final FocusNode searchFieldFocusNode;

  const SearchWidget({
    Key? key,
    required this.searchFieldFocusNode,
  }) : super(key: key);

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
        focusNode: widget.searchFieldFocusNode,
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
                ? const BorderSide(color: Colors.white, width: 2)
                : const BorderSide(color: Colors.white24),
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
  final FocusNode searchFieldFocusNode;

  const MainPageStateWidget({
    Key? key,
    required this.searchFieldFocusNode,
  }) : super(key: key);

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
                NoFavorites(
                  searchFieldFocusNode: searchFieldFocusNode,
                ),
              ],
            );
          case MainPageState.minSymbols:
            return const MinSymbols();
          case MainPageState.searchResults:
            return SuperheroesList(
                title: "Search results",
                stream: bloc.observeSearchedSuperheroes(),
            ableToSwipe: false,);
          case MainPageState.favorites:
            return SuperheroesList(
                title: "Your favorites",
                stream: bloc.observeFavoriteSuperheroes(), ableToSwipe: true,);
          case MainPageState.nothingFound:
            return NothingFound(
              searchFieldFocusNode: searchFieldFocusNode,
            );
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
    return const Align(
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
    return const Align(
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
  final FocusNode searchFieldFocusNode;

  const NoFavorites({Key? key, required this.searchFieldFocusNode})
      : super(key: key);

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
          onTap: () => searchFieldFocusNode.requestFocus()),
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;
  final bool ableToSwipe;

  const SuperheroesList({
    Key? key,
    required this.title,
    required this.stream,
    required this.ableToSwipe,
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
              return ListTitleWidget(title: title);
            }
            final SuperheroInfo item = superheroes[index - 1];
            return ListTile(superhero: item, ableToSwipe: ableToSwipe,);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 8);
          },
        );
      },
    );
  }
}

class ListTile extends StatelessWidget {
  final SuperheroInfo superhero;
  final bool ableToSwipe;

  const ListTile({
    Key? key,
    required this.superhero,
    required this.ableToSwipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    if(ableToSwipe) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Dismissible(
          key: ValueKey(superhero.id),
          child: SuperheroCard(
            superheroInfo: superhero,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SuperheroPage(
                        id: superhero.id,
                      )));
            },
          ),
          secondaryBackground: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: SuperheroesColors.red,
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16),
            child: Text(
              "Remove\nfrom\nfavorites".toUpperCase(),
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
          background: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: SuperheroesColors.red,
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16),
            child: Text(
              "Remove\nfrom\nfavorites".toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
          onDismissed: (_) => bloc.removeFromFavorites(superhero.id),
        ),
      );
    } else{
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SuperheroCard(
          superheroInfo: superhero,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    SuperheroPage(
                      id: superhero.id,
                    )));
          },
        ),
      );
    }
  }
}

class ListTitleWidget extends StatelessWidget {
  const ListTitleWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 90, bottom: 12),
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
}

class NothingFound extends StatelessWidget {
  final FocusNode searchFieldFocusNode;

  const NothingFound({
    Key? key,
    required this.searchFieldFocusNode,
  }) : super(key: key);

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
        onTap: () => searchFieldFocusNode.requestFocus(),
      ),
    );
  }
}

class LoadingError extends StatelessWidget {
  const LoadingError({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Center(
      child: InfoWithButton(
          title: "Error happened",
          subtitle: "Please, try again",
          buttonText: "Retry",
          assetImage: SuperheroesImages.superman,
          imageHeight: 106,
          imageWidth: 126,
          imageTopPadding: 22,
          onTap: bloc.retry),
    );
  }
}
