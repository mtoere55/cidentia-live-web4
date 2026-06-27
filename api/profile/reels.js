const { handleProfileTabRead } = require('./profileTabBoundary');
const {
  readProfileReelsByCid,
} = require('../../server/profile/profileTabsRepository');

module.exports = async function handler(req, res) {
  return handleProfileTabRead(req, res, {
    route: '/api/profile/reels',
    tab: 'reels',
    read: readProfileReelsByCid,
  });
};
