const { handleProfileTabRead } = require('./profileTabBoundary');
const {
  readProfilePostsByCid,
} = require('../../server/profile/profileTabsRepository');

module.exports = async function handler(req, res) {
  return handleProfileTabRead(req, res, {
    route: '/api/profile/posts',
    tab: 'posts',
    read: readProfilePostsByCid,
  });
};
