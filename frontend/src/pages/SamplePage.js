import React from 'react';

import Component from '../components/Component';

export default class SamplePage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div>
        <h1>Sample Page</h1>
        <Component />
      </div>
    );
  }
}
