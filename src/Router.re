[@react.component]
let make = () => {
  let url = ReasonReactRouter.useUrl();

  switch (url.path) {
  | [] => <MainPage />
  | ["signup"] => <Signup />
  | _ => <NotFound />
  };
};
