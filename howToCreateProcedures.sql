DROP FUNCTION IF EXISTS KB_calculateHeedfulByArtId;
DROP PROCEDURE IF EXISTS KB_createArticle;
DROP PROCEDURE IF EXISTS KB_createCategory;
DROP PROCEDURE IF EXISTS KB_createSubCategory;
DROP PROCEDURE IF EXISTS KB_deleteCategory;
DROP PROCEDURE IF EXISTS KB_deleteSubCategory;
DROP PROCEDURE IF EXISTS KB_getAccessibility;
DROP PROCEDURE IF EXISTS KB_getArticleBasicInfo;
DROP PROCEDURE IF EXISTS KB_getArticleById;
DROP PROCEDURE IF EXISTS KB_getArticlesBySubcatId;
DROP PROCEDURE IF EXISTS KB_getCategories;
DROP PROCEDURE IF EXISTS KB_getCollaboratorsByArtId;
DROP PROCEDURE IF EXISTS KB_getCommentsByArtId;
DROP PROCEDURE IF EXISTS KB_getCommentsReplyByArtId;
DROP PROCEDURE IF EXISTS KB_getLabels;
DROP PROCEDURE IF EXISTS KB_getLabelsByArtId;
DROP PROCEDURE IF EXISTS KB_getProducts;
DROP PROCEDURE IF EXISTS KB_getRelatedArticlesById;
DROP PROCEDURE IF EXISTS KB_getSubCategories;
DROP PROCEDURE IF EXISTS KB_getTypes;
DROP PROCEDURE IF EXISTS KB_searchArticlesByWord;
DROP PROCEDURE IF EXISTS KB_updateCategory;
DROP PROCEDURE IF EXISTS KB_updateSubCategory;
DROP PROCEDURE IF EXISTS KB_getLastStarredArticle;


delimiter //
create
  definer = root@`%` procedure KB_updateSubCategory(IN $id int, IN $categoryId int, IN $accesabilityId int,
                                                    IN $productID int, IN $subcat varchar(255))
BEGIN
  IF EXISTS(SELECT *
            FROM kb_subcategories
            WHERE id = $id)
  THEN
    UPDATE kb_subcategories
    SET category_id     = $categoryId,
        subcategory     = $subcat,
        product_id      = $productID,
        accesability_id = $accesabilityId
    WHERE id = $id;
    SELECT LAST_INSERT_ID() subcategoryID;

  END IF;
END//



create
  definer = root@`%` procedure KB_updateCategory(IN $id int, IN $category varchar(255), IN $accesabilityId int,
                                                 IN $productID int)
BEGIN
  IF EXISTS(SELECT *
            FROM kb_categories
            WHERE id = $id)
  THEN
    UPDATE kb_categories
    SET category        = $category,
        product_id      = $productID,
        accesability_id = $accesabilityId
    WHERE id = $id;

    SELECT LAST_INSERT_ID() categoryID;

  END IF;
END//


create
  definer = root@`%` procedure KB_getTypes()
BEGIN
   SELECT * FROM kb_types;
END//



create
  definer = root@`%` procedure KB_getSubCategories(IN $prodID int)
BEGIN

  IF $prodId NOT LIKE '0' THEN

    SELECT (SELECT COUNT(*)
            FROM kb_articles a
            WHERE a.product_id = $prodID
              AND a.subcategorie_id = c.id) AS articleCount,
           c.subcategory                    AS name,
           c.id,
           c.category_id
    FROM kb_subcategories c
    WHERE c.product_id = $prodId
    GROUP BY c.id;

  ELSE
    SELECT (SELECT COUNT(*)
            FROM kb_articles a
            WHERE a.subcategorie_id = c.id) AS articleCount,
           c.subcategory                    AS name,
           c.id,
           c.category_id
    FROM kb_subcategories c
    GROUP BY c.id;
  END IF;
END//



create
  definer = root@`%` procedure KB_getRelatedArticlesById(IN $id int)
BEGIN
  SELECT a.title, a.purpose, a.id
  FROM kb_articles a
         LEFT OUTER JOIN kb_article_to_article a2a ON a.id = a2a.related_article_id
  WHERE a2a.source_article_id = $id;
END//


create
  definer = root@`%` procedure KB_getProducts()
BEGIN
  SELECT * FROM kb_products;
END//



create
  definer = root@`%` procedure KB_getLastStarredArticle(IN $employeeId int)
BEGIN
  SET @id = (SELECT article_id FROM kb_starred_articles WHERE employee_id = $employeeId ORDER BY created_at LIMIT 1);

  CALL KB_getArticleBasicInfo(@id, $employeeId);
END//


create
  definer = root@`%` procedure KB_getLabelsByArtId(IN $id int)
BEGIN
  SELECT kb_labels.*
  FROM kb_labels
         JOIN kb_label_to_article l2a ON kb_labels.id = l2a.label_id
  WHERE l2a.article_id = $id;
END//



create
  definer = root@`%` procedure KB_getLabels()
BEGIN
   SELECT * FROM kb_labels;
END//


create
  definer = root@`%` procedure KB_getCommentsReplyByArtId(IN $id int)
BEGIN
  SELECT r.*, e.Name, e.Surname, e.avatar
  FROM kb_comment_replies r
         JOIN kb_comments c ON r.comment_id = c.id
         JOIN employees e on r.employee_id = e.EmployeeID
  where c.article_id = $id;
END//



create
  definer = root@`%` procedure KB_getCommentsByArtId(IN $id int)
BEGIN
  SELECT c.*, e.Name, e.Surname, e.avatar FROM kb_comments c
    JOIN employees e on c.employee_id = e.EmployeeID
  WHERE article_id = $id;
END//



create
  definer = root@`%` procedure KB_getCollaboratorsByArtId(IN $id int)
BEGIN
  SELECT e.Name, e.Surname, e.avatar
  FROM employees e
         LEFT OUTER JOIN kb_employee_to_article e2a ON e.EmployeeID = e2a.employee_id
  WHERE e2a.article_id = $id;
END//


create
  definer = root@`%` procedure KB_getCategories(IN $prodID int)
BEGIN

  IF $prodId NOT LIKE '0' THEN
    SELECT COUNT(a.id) AS articleCount,
           c.category  AS name,
           c.id
    FROM kb_articles a
           RIGHT OUTER JOIN kb_categories c on a.categorie_id = c.id
    WHERE a.product_id = $prodID
      AND c.product_id = $prodID
    GROUP BY c.id;
  ELSE
    SELECT COUNT(a.id) AS articleCount,
           c.category  AS name,
           c.id
    FROM kb_articles a
           RIGHT OUTER JOIN kb_categories c on a.categorie_id = c.id
    GROUP BY c.id;

  END IF;
END//



create
  definer = root@`%` procedure KB_getArticlesBySubcatId(IN $employeeId int, IN $prodId int, IN $subcatId int,
                                                        IN $catId int, IN $archiv int)
BEGIN

  IF $prodId NOT LIKE '0' THEN

    SELECT a.id,
           a.title,
           a.purpose,
           a.created_at,
           a.updated_at,
           a.keywords,
           a.is_archived,
           kha.is_helpful                            AS is_helpful,
           st.id                                     AS isStarred,
           acc.accessibility,
           (SELECT KB_calculateHeedfulByArtId(a.id)) AS helpfulRate # how are article helpful

    FROM kb_articles a
           LEFT OUTER JOIN kb_accessibilitys acc on a.accesability_id = acc.id
           LEFT OUTER JOIN kb_starred_articles st on a.id = st.article_id AND st.employee_id = $employeeId
           LEFT OUTER JOIN kb_heplful_article kha on a.id = kha.article_id AND kha.employee_id = $employeeId
    WHERE a.subcategorie_id = $subcatId
      AND a.product_id = $prodId
      AND a.categorie_id = $catId
      AND a.is_archived = $archiv;

  ELSE

    SELECT a.id,
           a.title,
           a.purpose,
           a.created_at,
           a.updated_at,
           a.keywords,
           a.is_archived,
           kha.is_helpful                            AS is_helpful,
           st.id                                     AS isStarred,
           acc.accessibility,
           (SELECT KB_calculateHeedfulByArtId(a.id)) AS helpfulRate # how are article helpful

    FROM kb_articles a
           LEFT OUTER JOIN kb_accessibilitys acc on a.accesability_id = acc.id
           LEFT OUTER JOIN kb_starred_articles st on a.id = st.article_id AND st.employee_id = $employeeId
           LEFT OUTER JOIN kb_heplful_article kha on a.id = kha.article_id AND kha.employee_id = $employeeId
    WHERE a.subcategorie_id = $subcatId
      AND a.categorie_id = $catId
      AND a.is_archived = $archiv;

  END IF;
END//



create
  definer = root@`%` procedure KB_getArticleById(IN $id int, IN $employeeId int)
BEGIN

  SET @isHelpful = (SELECT is_helpful FROM kb_heplful_article WHERE article_id = $id AND employee_id = $employeeId);
  SET @isStared = (SELECT id FROM kb_starred_articles WHERE article_id = $id AND employee_id = $employeeId);
  SET @helpfulRate = (SELECT KB_calculateHeedfulByArtId($id));

  SELECT a.*,                            # all from article
         e.Name       AS createorName,   # name of employee who create article
         e.Surname    AS createorSurname,
         e.EmployeeID AS idWhoCreateArt, # id of employee who crete article
         p.product,                      # product name
         @isHelpful   AS is_helpful,     # is article helpful for user
         @isStared    AS isStared,       # if != null -> article is starred by user
         @helpfulRate AS helpfulRate,    # how are article helpful
         cat.category,                   # value of category
         scat.subcategory,               # value of subcategory
         acc.accessibility               # accessibility of article
  FROM kb_articles a
         LEFT OUTER JOIN employees e ON e.EmployeeID = a.employee_id
         LEFT OUTER JOIN kb_products p on a.product_id = p.id
         LEFT OUTER JOIN kb_categories cat on a.categorie_id = cat.id
         LEFT OUTER JOIN kb_subcategories scat on a.subcategorie_id = scat.id
         LEFT OUTER JOIN kb_accessibilitys acc on a.accesability_id = acc.id
  WHERE a.id = $id;
END//



create
  definer = root@`%` procedure KB_getArticleBasicInfo(IN $id int, IN $employeeId int)
BEGIN

  SET @helpfulRate = (SELECT KB_calculateHeedfulByArtId($id));
  SET @isHelpful = (SELECT is_helpful FROM kb_heplful_article WHERE article_id = $id AND employee_id = $employeeId);
  SET @isStared = (SELECT id FROM kb_starred_articles WHERE article_id = $id AND employee_id = $employeeId);

  SELECT a.id,
         a.title,
         a.purpose,
         a.text,
         a.updated_at,
         a.created_at,
         a.keywords,
         @isHelpful  AS is_helpful,
         @isStared    AS isStarred,
         acc.accessibility,
         @helpfulRate AS helpfulRate # how are article helpful

  FROM kb_articles a
         LEFT OUTER JOIN kb_accessibilitys acc on a.accesability_id = acc.id
  WHERE a.id = $id;
END//



create
  definer = root@`%` procedure KB_getAccessibility()
BEGIN
  SELECT * FROM kb_accessibilitys;
END//



create
  definer = root@`%` procedure KB_deleteSubCategory(IN $id int)
BEGIN
  IF NOT EXISTS(SELECT *
                FROM kb_articles
                WHERE subcategorie_id = $id)
  THEN
    DELETE FROM kb_subcategories WHERE id = $id;
    SELECT LAST_INSERT_ID() subcategoryID;

  END IF;
END//



create
  definer = root@`%` procedure KB_deleteCategory(IN $id int)
BEGIN
  IF NOT EXISTS(SELECT *
                FROM kb_articles
                WHERE categorie_id = $id)
  THEN
    DELETE FROM kb_subcategories WHERE category_id = $id;
    DELETE FROM kb_categories WHERE id = $id;

    SELECT LAST_INSERT_ID() categoryID;

  END IF;
END//



create
  definer = root@`%` procedure KB_createSubCategory(IN $categoryId int, IN $accesabilityId int, IN $productID int,
                                                    IN $subcat varchar(255))
BEGIN

  SET @patentProduct = (SELECT product_id
                        FROM kb_categories
                        WHERE id = $categoryId);
  IF NOT EXISTS(SELECT *
                FROM kb_subcategories
                WHERE category_id = $categoryId
                  AND subcategory = $subcat
                  AND accesability_id = $accesabilityId
                  AND (product_id = $productID OR product_id = @patentProduct))
  THEN

    IF @patentProduct IS NOT NULL
    THEN
      INSERT INTO kb_subcategories (category_id, accesability_id, product_id, subcategory)
      VALUES ($categoryId, $accesabilityId, @patentProduct, $subcat);
    ELSE
      INSERT INTO kb_subcategories (category_id, accesability_id, product_id, subcategory)
      VALUES ($categoryId, $accesabilityId, $productID, $subcat);
    END IF;
    SELECT LAST_INSERT_ID() subcategoryID;
  END IF;
END//


create
  definer = root@`%` procedure KB_createCategory(IN $category varchar(255), IN $accesabilityId int, IN $productID int)
BEGIN
  IF NOT EXISTS(SELECT *
                FROM kb_categories
                WHERE category = $category
                  and accesability_id = $accesabilityId
                  AND (product_id = $productID
                   OR product_id IS NULL))
  THEN
    INSERT INTO kb_categories (category, accesability_id, product_id)
    VALUES ($category, $accesabilityId, $productID);

    SELECT LAST_INSERT_ID() categoryID;
  END IF;
END//



create
  definer = root@`%` procedure KB_createArticle(IN $title text, IN $purpose text, IN $text text, IN $categorieId int,
                                                IN $subcategorieId int, IN $accesabilityId int, IN $keywords text,
                                                IN $employeeId int, IN $productId int, IN $typeId int)
BEGIN

  IF EXISTS((SELECT * FROM kb_subcategories WHERE category_id = $categorieId AND id = $subcategorieId))
  THEN
    INSERT INTO kb_articles (title, purpose, text, categorie_id, subcategorie_id, accesability_id, keywords,
                             employee_id,
                             product_id, type_id, created_at, updated_at)
    VALUES ($title, $purpose, $text, $categorieId, $subcategorieId, $accesabilityId, $keywords,
            $employeeId, $productId, $typeId, utc_timestamp(), utc_timestamp());
    SELECT LAST_INSERT_ID() articleID;
  END IF;
END//


create
  definer = root@`%` function KB_calculateHeedfulByArtId(artId int) returns double
BEGIN
  DECLARE help DOUBLE;
  DECLARE allRate INT;
  DECLARE helpful DOUBLE;
  SET allRate = (SELECT COUNT(id) FROM kb_heplful_article WHERE article_id = artId);
  SET helpful = (SELECT COUNT(id) FROM kb_heplful_article WHERE article_id = artId AND is_helpful = 1);

  IF allRate NOT LIKE '0' THEN
    SET help = (helpful / allRate) * 100;
    RETURN help;
  ELSE
    RETURN NULL;
  END IF;
END//

delimiter ;
