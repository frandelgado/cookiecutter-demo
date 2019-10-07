import { SAMPLE_ACTION } from './actions';

const INITIAL_STATE = {};

function sampleReducer(state = INITIAL_STATE, action) {
  switch (action.type) {
    case SAMPLE_ACTION: {
      return 1;
    }

    default: {
      return state;
    }
  }
}

export default sampleReducer;
