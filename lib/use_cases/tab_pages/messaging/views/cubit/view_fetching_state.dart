part of 'view_cubit.dart';

abstract class ViewState extends Equatable {
  const ViewState();

  @override
  List<Object> get props => [];
}

class ViewInitial extends ViewState {}

class ViewFetchedState extends ViewState {
  final List<View> viewerIDs;

  ViewFetchedState(this.viewerIDs);

  @override
  List<Object> get props => [viewerIDs];
}

class ViewError extends ViewState {
  final String message;
  const ViewError(this.message);

  @override
  List<Object> get props => [message];
}
