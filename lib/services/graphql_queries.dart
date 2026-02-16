/// Fichier centralisant toutes les requêtes GraphQL pour l'API WordPress

// Requête : Navigation - Récupérer le menu principal
String navQuery() {
  return '''
    query GetMenuItems {
      menus {
        edges {
          node {
            id
            name
            slug
            menuItems {
              edges {
                node {
                  id
                  label
                  url
                  childItems {
                    edges {
                      node {
                        id
                        label
                        url
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';
}

// Requête : Articles - Récupérer les derniers posts
String findLatestPostsAPI({int first = 10, String? after}) {
  return '''
    query GetLatestPosts(\$first: Int!, \$after: String) {
      posts(first: \$first, after: \$after) {
        pageInfo {
          endCursor
          hasNextPage
        }
        edges {
          node {
            id
            title
            slug
            excerpt
            date
            content
            featuredImage {
              node {
                sourceUrl
                altText
              }
            }
            acf {
              video_url
              video
              videoUrl
            }
            categories {
              edges {
                node {
                  id
                  name
                  slug
                }
              }
            }
          }
        }
      }
    }
  ''';
}

// Requête : Page Actualités - Récupérer articles avec pagination
String newsPagePostsQuery({int first = 10, String? after}) {
  return '''
    query GetNewsPosts(\$first: Int!, \$after: String) {
      posts(first: \$first, after: \$after) {
        pageInfo {
          endCursor
          hasNextPage
        }
        edges {
          node {
            id
            title
            slug
            excerpt
            date
            content
            featuredImage {
              node {
                sourceUrl
                altText
              }
            }
            acf {
              video_url
              video
              videoUrl
            }
            author {
              node {
                name
              }
            }
            categories {
              edges {
                node {
                  id
                  name
                  slug
                }
              }
            }
          }
        }
      }
    }
  ''';
}

// Requête : Récupérer un nœud par URI (Post, Page, Catégorie)
String getNodeByURI(String uri) {
  return '''
    query GetNodeByURI(\$uri: String!) {
      nodeByUri(uri: \$uri) {
        ... on Post {
          id
          title
          content
          excerpt
          date
          slug
          featuredImage {
            node {
              sourceUrl
              altText
            }
          }
          acf {
            video_url
            video
            videoUrl
          }
          categories {
            edges {
              node {
                id
                name
                slug
              }
            }
          }
          author {
            node {
              name
              avatar {
                url
              }
            }
          }
        }
        ... on Page {
          id
          title
          content
          excerpt
          date
          slug
          featuredImage {
            node {
              sourceUrl
              altText
            }
          }
        }
        ... on Category {
          id
          name
          description
          slug
          posts(first: 20) {
            edges {
              node {
                id
                title
                slug
                excerpt
                date
                featuredImage {
                  node {
                    sourceUrl
                    altText
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';
}

// Requête : Récupérer un Post par slug (idType: SLUG)
String getPostBySlugQuery() {
  return '''
    query GetPostBySlug(\$slug: ID!) {
      post(id: \$slug, idType: SLUG) {
        id
        title
        content
        excerpt
        date
        slug
        featuredImage {
          node {
            sourceUrl
            altText
          }
        }
          acf {
            video_url
            video
            videoUrl
          }
        categories {
          edges {
            node {
              id
              name
              slug
            }
          }
        }
        author {
          node {
            name
            avatar {
              url
            }
          }
        }
      }
    }
  ''';
}

// Requête : Équipe - Récupérer tous les membres
String getAllMembers() {
  return '''
    query GetAllMembers {
      equipes(where: {status: PUBLISH}, first: 100) {
        nodes {
          id
          title
          featuredImage {
            node {
              altText
              mediaItemUrl
              sourceUrl
            }
          }
          social {
            facebook
            instagram
            linkedin
            twitter
          }
          content
          excerpt
        }
      }
    }
  ''';
}

// Requête : Récupérer toutes les catégories
String getAllCategoriesQuery() {
  return '''
    query GetAllCategories {
      categories(first: 100) {
        edges {
          node {
            id
            name
            slug
            description
          }
        }
      }
    }
  ''';
}

// Requête : Recherche - Articles par mot-clé
String searchPostsQuery(String searchTerm, {int first = 10}) {
  return '''
    query SearchPosts(\$search: String!, \$first: Int!) {
      posts(first: \$first, where: { search: \$search }) {
        edges {
          node {
            id
            title
            slug
            excerpt
            date
            featuredImage {
              node {
                sourceUrl
                altText
              }
            }
          }
        }
      }
    }
  ''';
}

// Requête : Récupérer articles d'une catégorie
String getPostsByCategoryQuery(
  String categorySlug, {
  int first = 10,
  String? after,
}) {
  return '''
    query GetPostsByCategory(\$slug: String!, \$first: Int!, \$after: String) {
      categories(where: { slug: \$slug }, first: 1) {
        edges {
          node {
            id
            name
            slug
            description
            posts(first: \$first, after: \$after) {
              pageInfo {
                endCursor
                hasNextPage
              }
              edges {
                node {
                  id
                  title
                  slug
                  excerpt
                  date
                  featuredImage {
                    node {
                      sourceUrl
                      altText
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';
}

// Requête : Récupérer données pour page d'accueil (sections)
String homePageDataQuery() {
  return '''
    query GetHomePageData {
      latestPosts: posts(first: 5) {
        edges {
          node {
            id
            title
            slug
            excerpt
            date
            featuredImage {
              node {
                sourceUrl
                altText
              }
            }
          }
        }
      }
      
      featuredCategory: categories(first: 1, where: { slug: "featured" }) {
        edges {
          node {
            id
            name
            slug
            posts(first: 5) {
              edges {
                node {
                  id
                  title
                  slug
                  excerpt
                  date
                  featuredImage {
                    node {
                      sourceUrl
                      altText
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';
}
