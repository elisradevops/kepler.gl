// SPDX-License-Identifier: MIT
// Copyright contributors to the kepler.gl project

export const OFFLINE_MAP_STYLE_ID = 'offline';

export const OFFLINE_MAP_STYLE = {
  id: OFFLINE_MAP_STYLE_ID,
  label: 'Offline',
  custom: true,
  accessToken: null,
  style: {
    version: 8,
    name: 'Offline',
    sources: {},
    layers: [
      {
        id: 'background',
        type: 'background',
        paint: {
          'background-color': '#1f1f1f'
        }
      }
    ]
  }
};
