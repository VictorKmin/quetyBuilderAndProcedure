'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {

    try {
      await queryInterface.createTable('kb_accessibilitys', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        accessibility: {
          type: Sequelize.STRING(255),
          allowNull: false
        },
      });
      await queryInterface.createTable('kb_products', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        product: {
          type: Sequelize.STRING(255),
          allowNull: false
        },
      });
      await queryInterface.createTable('kb_types', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        type: {
          type: Sequelize.STRING(60),
          allowNull: false
        },
      });
      await queryInterface.createTable('kb_labels', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        label: {
          type: Sequelize.STRING(255),
          allowNull: false
        },
      });
      await queryInterface.createTable('kb_categories', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        category: {
          type: Sequelize.STRING(255),
          allowNull: false
        },
        accesability_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_accessibilitys',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        product_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_products',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        }
      });
      await queryInterface.createTable('kb_subcategories', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        category_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_categories',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        accesability_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_accessibilitys',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        product_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_products',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        subcategory: {
          type: Sequelize.STRING(255),
          allowNull: false,
        }
      });
      await queryInterface.createTable('kb_articles', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true,
        },
        title: {
          type: Sequelize.TEXT,
          allowNull: false,
        },
        purpose: {
          type: Sequelize.TEXT,
          allowNull: false,
        },
        text: {
          type: Sequelize.TEXT,
          allowNull: false,
        },
        employee_id: {
          allowNull: true,
          type: Sequelize.INTEGER,
          references: {
            model: 'employees',
            key: 'EmployeeID'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: false,
          default: new Date()
        },
        updated_at: {
          type: Sequelize.DATE,
          allowNull: false,
          default: new Date()
        },
        categorie_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_categories',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        subcategorie_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_subcategories',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        accesability_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_accessibilitys',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        keywords: {
          type: Sequelize.TEXT,
          allowNull: false,
        },
        type_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_types',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        product_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_products',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        is_archived: {
          type: Sequelize.BOOLEAN,
          allowNull: false,
          defaultValue: false
        }
      }, {
        indexes: [
          {
            type: 'FULLTEXT',
            name: 'fulltext',
            unique: true,
            fields: ['title', 'purpose', 'text']
          }
        ]
      });
      await queryInterface.createTable('kb_employee_to_article', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        employee_id: {
          allowNull: true,
          type: Sequelize.INTEGER,
          references: {
            model: 'employees',
            key: 'EmployeeID'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        article_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_articles',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        }
      });
      await queryInterface.createTable('kb_comments', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        comment: {
          type: Sequelize.TEXT,
          allowNull: false
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: false,
          default: new Date()
        },
        updated_at: {
          type: Sequelize.DATE,
          allowNull: false,
          default: new Date()
        },
        employee_id: {
          allowNull: true,
          type: Sequelize.INTEGER,
          references: {
            model: 'employees',
            key: 'EmployeeID'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        article_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_articles',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        }
      });
      await queryInterface.createTable('kb_starred_articles', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        employee_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'employees',
            key: 'EmployeeID'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        article_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_articles',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: false,
          default: new Date()
        }
      });
      await queryInterface.createTable('kb_article_to_article', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        source_article_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_articles',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        related_article_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_articles',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        }
      });
      await queryInterface.createTable('kb_label_to_article', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        label_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_labels',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        article_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_articles',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        }
      });
      await queryInterface.createTable('kb_heplful_article', {
        id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true
        },
        article_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'kb_articles',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        is_helpful: {
          type: Sequelize.BOOLEAN,
          allowNull: false
        },
        employee_id: {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'employees',
            key: 'EmployeeID'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: false,
          default: new Date()
        }
      });
      await queryInterface.createTable('kb_comment_replies', {
        id: {
          allowNull: false,
          primaryKey: true,
          autoIncrement: true,
          type: Sequelize.INTEGER
        },
        comment_id: {
          allowNull: true,
          type: Sequelize.INTEGER,
          references: {
            model: 'kb_comments',
            key: 'id'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        comment: {
          type: Sequelize.TEXT,
          allowNull: false
        },
        employee_id: {
          allowNull: true,
          type: Sequelize.INTEGER,
          references: {
            model: 'employees',
            key: 'EmployeeID'
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        },
        created_at: {
          allowNull: false,
          type: Sequelize.DATE,
          default: new Date()
        },
        updated_at: {
          allowNull: false,
          type: Sequelize.DATE,
          default: new Date()
        }
      });


      return Promise.resolve()
    } catch (e) {
      console.log(e);
    }


    /*
      Add altering commands here.
      Return a promise to correctly handle asynchronicity.

      Example:
      return queryInterface.bulkInsert('People', [{
        name: 'John Doe',
        isBetaMember: false
      }], {});
    */

  },

  down: async (queryInterface, Sequelize) => {
    /*
      Add reverting commands here.
      Return a promise to correctly handle asynchronicity.

      Example:
      return queryInterface.bulkDelete('People', null, {});
    */
    try {
      await queryInterface.dropTable('kb_article_to_article', {});
      await queryInterface.dropTable('kb_article_accessibility', {});
      await queryInterface.dropTable('kb_helpful_article', {});
      await queryInterface.dropTable('kb_label_to_article', {});
      await queryInterface.dropTable('kb_starred_articles', {});
      await queryInterface.dropTable('kb_comment_replies', {});
      await queryInterface.dropTable('kb_comments', {});
      await queryInterface.dropTable('kb_subcategories', {});
      await queryInterface.dropTable('kb_categories', {});
      await queryInterface.dropTable('kb_products', {});
      await queryInterface.dropTable('kb_types', {});
      await queryInterface.dropTable('kb_labels', {});
      await queryInterface.dropTable('kb_articles', {});
      await queryInterface.dropTable('kb_accessibilitys', {});


      return Promise.resolve()
    } catch (e) {
      console.log(e);
    }

  }
};
