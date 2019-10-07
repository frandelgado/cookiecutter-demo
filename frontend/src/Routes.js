import React, { Component, Fragment } from 'react';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

import SamplePage from './pages/SamplePage';

export default class Routes extends Component {
  renderRoutes = () => (
    // Add logic if routes depend on user authentication

    <Router>
      <Switch>
        {/* Home */}
        <Route exact path="/" component={SamplePage} />
      </Switch>
    </Router>
  );

  render() {
    return <Fragment>{this.renderRoutes()}</Fragment>;
  }
}
