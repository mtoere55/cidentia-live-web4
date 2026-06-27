const { handleProfileTabRead } = require('./profileTabBoundary');
const {
  readProfileMediaByCid,
} = require('../../server/profile/profileTabsRepository');

module.exports = async function handler(req, res) {
  return handleProfileTabRead(req, res, {
    route: '/api/profile/media',
    tab: 'media',
    read: readProfileMediaByCid,
  });
};
