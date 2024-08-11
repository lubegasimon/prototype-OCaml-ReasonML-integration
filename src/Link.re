let handleClick = (href, event) =>
  if (!React.Event.Mouse.defaultPrevented(event)) {
    React.Event.Mouse.preventDefault(event);
    ReasonReactRouter.push(href);
  };

[@react.component]
let make = (~href, ~children) => {
  <div>
    <div>
      <a href onClick={event => handleClick(href, event)}> children </a>
    </div>
  </div>;
};
